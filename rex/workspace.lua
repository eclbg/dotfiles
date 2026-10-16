-- Save structural state and best-effort foreground commands, not live processes.
local terminal = "com.superlogical.terminal"
local state = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/rex"
local snapshot = state .. "/workspace.lua"

local function checked(result, err)
  if not result then error(err or "Rex request failed", 0) end
  return result
end

local function quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local shells = { zsh = true, bash = true, sh = true, fish = true, dash = true,
  ksh = true, tcsh = true, csh = true, nu = true, login = true }

local function running_command(process)
  if not process or not process.pid then return nil end
  local name = (process.name or ""):match("[^/]+$") or ""
  if shells[name:gsub("^-", "")] then return nil end
  local pipe = io.popen("ps -ww -p " .. string.format("%d", process.pid) .. " -o command=", "r")
  if not pipe then return nil end
  local command = pipe:read("*a"):gsub("\n$", "")
  pipe:close()
  -- Never inject line breaks or terminal control sequences. No Enter is sent.
  if command == "" or command:find("[%z\1-\31\127]") then return nil end
  return command
end

local function encode(value)
  if type(value) == "table" then
    local entries = {}
    for key, item in pairs(value) do
      entries[#entries + 1] = "[" .. encode(key) .. "]=" .. encode(item)
    end
    return "{" .. table.concat(entries, ",") .. "}"
  elseif type(value) == "string" then
    return string.format("%q", value)
  end
  return tostring(value)
end

rex.action{
  name = "save_workspace",
  title = "Save Workspace",
  description = "Save all sessions, tabs, panes, directories, and recoverable running commands.",
  run = function()
    local saved = { version = 2, sessions = {} }
    local commands = 0
    for _, session in ipairs(checked(rex.call("session.list")).sessions or {}) do
      local view = checked(rex.call("session.attach", { session_id = session.session_id })).view
      for _, window in ipairs(view.windows or {}) do
        for _, layer in ipairs(window.layers or {}) do
          for _, block in ipairs(layer.blocks or {}) do
            if block.creator_name ~= terminal then
              error("Cannot save non-terminal pane " .. block.block_id, 0)
            end
            local args = { session_id = session.session_id, block_id = block.block_id }
            local process = checked(rex.block.call(terminal, "process", args))
            local pwd = checked(rex.block.call(terminal, "pwd", args)).pwd
            -- Shell-reported pwd is a URL; process cwd is a plain-path fallback.
            block.cwd = pwd and pwd:match("^file://[^/]*(/.*)")
            if block.cwd then
              block.cwd = block.cwd:gsub("%%(%x%x)", function(hex)
                return string.char(tonumber(hex, 16))
              end)
            else
              block.cwd = (process.foreground and process.foreground.cwd)
                or (process.child and process.child.cwd)
            end
            if not block.cwd or block.cwd == "" then
              error("Cannot determine directory for pane " .. block.block_id, 0)
            end
            block.command = running_command(process.foreground)
            if block.command then commands = commands + 1 end
          end
        end
      end
      saved.sessions[#saved.sessions + 1] = view
    end
    if #saved.sessions == 0 then error("No sessions to save; keeping the previous snapshot", 0) end
    os.execute("umask 077; mkdir -p " .. quote(state))
    -- Create privately, then rename so a failed save cannot truncate the snapshot.
    os.execute("umask 077; : > " .. quote(snapshot .. ".tmp"))
    local file = checked(io.open(snapshot .. ".tmp", "wb"))
    checked(file:write("return " .. encode(saved) .. "\n"))
    checked(file:close())
    checked(os.rename(snapshot .. ".tmp", snapshot))
    return { sessions = #saved.sessions, commands = commands, path = snapshot }
  end,
}

rex.action{
  name = "restore_workspace",
  title = "Restore Workspace",
  description = "Recreate the saved workspace as new sessions; prepare commands without running them.",
  run = function()
    local file = checked(io.open(snapshot, "rb"))
    local source = file:read("*a")
    file:close()
    if source:sub(1, 7) ~= "return " then error("Invalid workspace snapshot", 0) end
    local load = checked(loadstring(source, "workspace snapshot"))
    setfenv(load, {})
    local saved = load()
    if saved.version ~= 2 then error("Save Workspace again to update the snapshot format", 0) end
    local created = {}
    local ok, err = pcall(function()
      for _, view in ipairs(saved.sessions) do
        local sid = checked(rex.call("session.create", { label = view.label })).session_id
        created[#created + 1] = sid
        checked(rex.call("session.attach", { session_id = sid }))
        local blocks, windows = {}, {}
        for _, window in ipairs(view.windows or {}) do
          local wid
          for _, layer in ipairs(window.layers or {}) do
            local metadata, leaves = {}, {}
            for _, block in ipairs(layer.blocks or {}) do metadata[block.block_id] = block end
            local function layout(node)
              if node.split then
                return { split = {
                  direction = node.split.direction, ratio = node.split.ratio,
                  before = layout(node.split.before), after = layout(node.split.after),
                } }
              end
              local block = metadata[node.block_id]
              if block.command and block.command:find("[%z\1-\31\127]") then
                error("Unsafe command text in workspace snapshot", 0)
              end
              leaves[#leaves + 1] = node.block_id
              return { block = {
                flavor = "com.superlogical.terminal.shell", label = block.label,
                options = {
                  cwd = block.cwd, initial_input = block.command or "",
                },
              } }
            end
            local tree = layout(layer.layout)
            local result
            if layer.kind == "tiled" then
              result = checked(rex.session.new_window{
                session_id = sid, window_label = window.label, layout = tree,
              })
              wid = result.window_id
              windows[window.window_id] = wid
            else
              result = checked(rex.session.new_layer{
                session_id = sid, window_id = wid, bounds = layer.bounds, layout = tree,
              })
            end
            for index, id in ipairs(result.block_ids) do blocks[leaves[index]] = id end
          end
          if blocks[window.focused_block_id] then
            checked(rex.session.focus_block{ session_id = sid, block_id = blocks[window.focused_block_id] })
          end
          if blocks[window.zoomed_block_id] then
            checked(rex.session.zoom_block{ session_id = sid, block_id = blocks[window.zoomed_block_id], zoom = true })
          end
        end
        if windows[view.active_window_id] then
          checked(rex.session.focus_window{ session_id = sid, window_id = windows[view.active_window_id] })
        end
      end
    end)
    if not ok then
      for _, sid in ipairs(created) do rex.call("session.destroy", { session_id = sid }) end
      error(err, 0)
    end
    return { sessions = #created }
  end,
}
