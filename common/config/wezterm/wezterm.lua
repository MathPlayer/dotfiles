local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- Snippet taken from:
-- https://wezfurlong.org/wezterm/config/lua/wezterm.gui/get_appearance.html
-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux.
local appearance = 'Dark'
if wezterm.gui then
    appearance = wezterm.gui.get_appearance()
end

-- font

-- Determines the font to use based on the operating system.
local font = 'JetBrains Mono'
if wezterm.target_triple:find('apple') then
  -- font = 'MesloLGS NF', -- From p10k
  font = 'Hack Nerd Font Mono'
elseif wezterm.target_triple == 'x86_64-unknown-linux-gnu' then
  font = 'MesloLGS Nerd Font Mono'
end
config.font = wezterm.font_with_fallback { font }
config.font_size = 14
config.line_height = 1.1

-- appearance

if appearance:find('Dark') then
  -- color_scheme = 'Builtin Solarized Dark'
  -- color_scheme = 'Gruvbox dark, medium (base16)',
  color_scheme = 'OneDark (base16)'
  -- color_scheme = 'Tokyo Night'
else
  -- color_scheme = 'Builtin Solarized Light'
  -- color_scheme = 'Gruvbox light, medium (base16)'
  color_scheme = 'One Light (base16)'
  -- color_scheme = 'Tokyo Night Day'

end

config.color_scheme = color_scheme
config.colors = {
  -- Color for the line between split panes
  split = 'grey'
}
-- Color for the scroll part representing the current view.
if appearance:find('Dark') then
  config.colors.scrollbar_thumb = "#606060"
else
  config.colors.scrollbar_thumb = "#a0a0a0"
end

-- The default tab bar colors work only for a dark appearance.
if appearance:find('Light') then
  config.window_frame = {
    active_titlebar_bg = '#eeeeee',
    inactive_titlebar_bg = '#eeeeee',
  }
  config.colors.tab_bar = {
    active_tab = {
      bg_color = '#cccccc',
      fg_color = '#555555',
    },
    inactive_tab = {
      bg_color = '#eeeeee',
      fg_color = '#777777',
    },
    inactive_tab_hover = {
      bg_color = '#dddddd',
      fg_color = '#666666',
    },
    new_tab = {
      bg_color = '#eeeeee',
      fg_color = '#111111',
    },
    new_tab_hover = {
      bg_color = '#dddddd',
      fg_color = '#666666',
    },
  }
end

-- dim the inactive pane
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.6,
}

-- keyboard shortcuts
config.keys = {
  {
    -- new horizontal split pane; default shortcut is CTRL + ALT + SHIFT + %
    key = 'd',
     mods = 'SUPER',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    -- new vertical split pane; default shortcut is CTRL + ALT + SHIFT + "
    key = 'D',
    mods = 'SUPER|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    -- panel selection modal display
    key = 'Space',
    mods = 'SUPER|SHIFT',
    action = wezterm.action.PaneSelect,
  }
}

-- misc
config.hide_tab_bar_if_only_one_tab = true
config.enable_scroll_bar = true
-- set a custom TERM for better handling of certain modern features like undercurl and similar.
-- requires also to get a specific terminfo config for wezterm in ~/.terminfo.
-- From: https://wezfurlong.org/wezterm/config/lua/config/term.html, the snippet run:
--   tempfile=$(mktemp) \
--   && curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo \
--   && tic -x -o ~/.terminfo $tempfile \
--   && rm $tempfile
config.term = "wezterm"

return config
