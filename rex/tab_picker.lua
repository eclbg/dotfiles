-- Loaded by init.lua to register the action, and run by `rex do` in the popup.
local source = debug.getinfo(1, "S").source:gsub("^@", "")

local function checked(result, err)
  if not result then error(err or "Rex request failed", 0) end
  return result
end

local function quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function label(value)
  return (value or ""):gsub("[%z\1-\31\127]", " ")
end

if rex.args then
  local global, query = false, ""
  while true do
    local sessions = global and checked(rex.call("session.list")).sessions
      or { { session_id = rex.args.session_id } }
    local rows = {}
    for _, session in ipairs(sessions or {}) do
      -- A session may have disappeared since session.list returned.
      -- Cross-session reads require attaching this script's control connection.
      local attached = rex.call("session.attach", { session_id = session.session_id })
      local view = attached and attached.view
      if view then
        for index, window in ipairs(view.windows or {}) do
          local title = label(window.label)
          if title == "" then
            -- Unnamed tabs use their focused terminal's title, like the tab bar.
            -- The popup must not replace the originating tab's title.
            local block_id = window.focused_block_id
            if block_id == rex.block_id then block_id = rex.args.origin_block_id end
            local result = rex.block.call("com.superlogical.terminal", "title", {
              session_id = session.session_id, block_id = block_id,
            })
            title = label(result and result.title)
          end
          if title == "" then title = "Untitled" end
          local name = index .. " · " .. title
          if global then name = label(view.label) .. " · " .. name end
          rows[#rows + 1] = session.session_id .. "\t" .. window.window_id .. "\t" .. name
        end
      end
    end
    local prompt = global and "All sessions > " or "Current session > "
    local result = checked(rex.exec({
      "fzf", "--no-multi", "--layout=reverse", "--border", "--delimiter=\t", "--with-nth=3..",
      "--color=light,bg:#fafafa,bg+:#e5e7eb,fg:#202020,fg+:#111111,gutter:#fafafa,border:#9ca3af",
      "--expect=ctrl-a", "--print-query",
      "--header=Enter: switch · Ctrl+A: current/all sessions · Esc: cancel",
      "--prompt=" .. prompt, "--query=" .. query,
    }, { stdin = table.concat(rows, "\n"), env = { FZF_DEFAULT_OPTS = "", FZF_DEFAULT_OPTS_FILE = "" } }))
    if result.code == 130 or result.code == 1 then break end
    if not result.ok then error(result.stderr, 0) end
    local key, selected
    query, key, selected = result.stdout:match("^([^\n]*)\n([^\n]*)\n([^\n]*)")
    if key == "ctrl-a" then
      global = not global
    else
      if key == "" and selected then
        local sid, wid = selected:match("^([^\t]+)\t([^\t]+)\t")
        rex.client.queue("session.select", { session_id = sid, window_id = wid })
      end
      break
    end
  end
else
  rex.action{
    name = "pick_tab",
    title = "Search Tabs",
    description = "Fuzzy search this session's tabs; Ctrl+A toggles all sessions.",
    run = function(ctx)
      local command = "exec rex -C " .. quote(ctx.client_id) .. " do " .. quote(source)
        .. " " .. quote("session_id=" .. ctx.session_id)
        .. " " .. quote("origin_block_id=" .. (ctx.block_id or ""))
      return checked(rex.session.new_layer{
        bounds = { 0.1, 0.15, 0.8, 0.7 }, focus = true,
        layout = { block = {
          flavor = "com.superlogical.terminal.shell", label = "Search Tabs",
          options = {
            shell = "none", command = { "/bin/zsh", "-lc", command },
            exit = { on_completion = true },
          },
        } },
      })
    end,
  }
  rex.bind("ctrl+space>w", "pick_tab")
end
