local wezterm = require 'wezterm'

return {
  -- appearance
  -- color_scheme = 'Gruvbox dark, medium (base16)',
  color_scheme = 'OneDark (base16)',

  colors = {
    -- The color of the scrollbar "thumb"; the portion that represents the current viewport
    scrollbar_thumb='#444444',
    -- The color of the split lines between panes
    split = '#666666',
  },
  -- dim the inactive pane
  inactive_pane_hsb = {
    brightness = 0.5, -- default is 0.8
  },

  -- font
  font = wezterm.font_with_fallback {
    'Hack Nerd Font Mono',
  },
  font_size = 14,
  line_height = 1.1,

  -- keyboard shortcuts
  keys = {
    -- new horizontal split pane; default shortcut is CTRL + ALT + SHIFT + %
    {
      key = 'd',
      mods = 'SUPER',
      action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    -- new vertical split pane (default shortcut is CTRL + ALT + SHIFT + "
    {
      key = 'D',
      mods = 'SUPER|SHIFT',
      action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },
  },

  -- misc
  hide_tab_bar_if_only_one_tab = true,
  enable_scroll_bar = true,
}
