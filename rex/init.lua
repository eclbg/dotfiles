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
for _, direction in ipairs({ "left", "down", "up", "right" }) do
  rex.bind("ctrl+space>" .. direction, "pane.focus", {
    direction = direction,
    wrap = false,
  })
end

-- Rex's native session picker replaces the tmux/fzf popup (not its previews).
rex.bind("ctrl+space>g", "session.switch")
rex.bind("ctrl+space>s", "session.switch")
rex.bind("ctrl+space>shift+4", "session.rename") -- $

-- Intentionally not ported yet:
-- * Ctrl+\: no previous-pane binding yet.
-- * Prefix+[: Rex currently has no keyboard selection/copy-mode actions.
-- * Prefix+T (floax), resurrect, and tmux-open: no direct action equivalents.
-- * Ghostty's raw Ctrl+I escape sequence and left-Option-as-Alt setting:
--   terminal input behavior needs checking separately in Rex.
