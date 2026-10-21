-- Tmux muscle memory, with Ctrl+Space as the prefix.
-- Fonts, colors, and other appearance settings stay under Rex's control.
-- Existing Rex shortcuts remain available alongside these bindings.

rex.bind("ctrl+space>ctrl+space", "pane.send_key", { key = "ctrl+space" })
rex.bind("ctrl+space>shift+;", "client.palette.toggle") -- : on a US layout

-- Tmux windows are Rex tabs. Keep tmux's default zero-based key numbering;
-- Rex's tab indices are one-based (prefix+0 selects the first tab).
rex.bind("ctrl+space>c", "client.tab.new")
rex.bind("ctrl+space>n", "client.tab.next")
rex.bind("ctrl+space>p", "client.tab.previous")
rex.bind("ctrl+space>,", "client.tab.rename")
rex.bind("ctrl+space>shift+7", "client.tab.close") -- & on a US layout
for number = 0, 9 do
  rex.bind("ctrl+space>" .. number, "client.tab.goto", { index = number + 1 })
end

-- Use the client's built-in split actions, including directory inheritance.
rex.bind("ctrl+space>shift+5", "pane.split", { direction = "right" }) -- %
rex.bind("ctrl+space>shift+'", "pane.split", { direction = "down" }) -- "
rex.bind("ctrl+space>z", "pane.zoom")
rex.bind("ctrl+space>x", "pane.close")
rex.bind("ctrl+space>o", "pane.focus_next")

-- Swap with the previous/next pane in layout order, wrapping like tmux { / }.
-- Stay within the current layer; do not swap into other tabs or floating layers.
for key, step in pairs({ ["shift+["] = -1, ["shift+]"] = 1 }) do
  rex.bind("ctrl+space>" .. key, function(ctx)
    local view = rex.session.view{}
    if not view then
      return true
    end
    for _, window in ipairs(view.windows) do
      for _, layer in ipairs(window.layers) do
        local panes = {}
        local function collect(node)
          if node.block_id then
            panes[#panes + 1] = node.block_id
          elseif node.split then
            collect(node.split.before)
            collect(node.split.after)
          end
        end
        collect(layer.layout)
        for index, block_id in ipairs(panes) do
          if block_id == ctx.block_id then
            if #panes > 1 then
              rex.session.swap_blocks{
                block_id = block_id,
                other_block_id = panes[(index - 1 + step) % #panes + 1],
              }
            end
            return true
          end
        end
      end
    end
    return true
  end)
end

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, function(ctx)
    local process = rex.block.call("com.superlogical.terminal", "process", {
      block_id = ctx.block_id,
    })
    -- If detection fails, leave the key to the terminal rather than steal it.
    if not process or not process.foreground then
      return false
    end
    local name = process.foreground.name:match("[^/]+$")
    if name == "vim" or name == "nvim" or name == "vimdiff"
      or name == "nvimdiff" or name == "view" or name == "nview" then
      return false
    end
    local result = rex.session.focus_direction{ direction = direction, wrap = false }
    return result ~= nil
  end)
  rex.bind("ctrl+space>" .. key, "pane.focus", {
    direction = direction,
    wrap = false,
  })
end

rex.action{
  name = "start_resize",
  title = "Start Resizing Pane",
  args = { direction = "string" },
  run = function(ctx, args)
    rex.client.queue("pane.resize", { direction = args.direction, amount = 1 })
    rex.client.queue("client.mode.enter", { name = "resize" })
  end,
}

for _, direction in ipairs({ "left", "down", "up", "right" }) do
  rex.bind("ctrl+space>" .. direction, "pane.focus", {
    direction = direction,
    wrap = false,
  })
  -- Start resizing with the prefix, then repeat Ctrl+arrows until Escape.
  rex.bind("ctrl+space>ctrl+" .. direction, "start_resize", {
    direction = direction,
  })
  rex.bind("resize/ctrl+" .. direction, "pane.resize", {
    direction = direction,
    amount = 1,
  })
end

-- Rex's native session picker replaces the tmux/fzf popup (not its previews).
rex.bind("ctrl+space>g", "session.switch")
rex.bind("ctrl+space>s", "session.switch")
rex.bind("ctrl+space>shift+4", "session.rename") -- $

-- Fuzzy tab picker: current session by default, Ctrl+A for all sessions.
require("tab_picker")

-- Workspace snapshots are available in the command palette, without shortcuts.
require("workspace")

-- Intentionally not ported yet:
-- * Ctrl+\: no previous-pane binding yet.
-- * Prefix+[: Rex currently has no keyboard selection/copy-mode actions.
-- * Prefix+T (floax), resurrect, and tmux-open: no direct action equivalents.
-- * Ghostty's raw Ctrl+I escape sequence and left-Option-as-Alt setting:
--   terminal input behavior needs checking separately in Rex.
