local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- =============================================================================
-- Colors: Catppuccin Mocha with black background (matches Neovim override)
-- =============================================================================
config.color_scheme = "Catppuccin Mocha"
config.colors = {
  background = "#000000",
  tab_bar = {
    background = "#000000",
    active_tab = { bg_color = "#1e1e2e", fg_color = "#cdd6f4" },
    inactive_tab = { bg_color = "#000000", fg_color = "#585b70" },
    inactive_tab_hover = { bg_color = "#181825", fg_color = "#cdd6f4" },
    new_tab = { bg_color = "#000000", fg_color = "#585b70" },
    new_tab_hover = { bg_color = "#181825", fg_color = "#cdd6f4" },
  },
}

-- =============================================================================
-- Font: RecMonoDuotone Nerd Font (matches Ghostty config)
-- =============================================================================
config.font = wezterm.font("RecMonoDuotone Nerd Font")
config.font_size = 13.0
config.line_height = 1.3
-- Disable ligatures (matches Ghostty: -calt, -liga, -dlig)
config.harfbuzz_features = { "calt=0", "liga=0", "dlig=0" }

-- =============================================================================
-- Cursor: Steady block, no blink (matches Ghostty)
-- =============================================================================
config.default_cursor_style = "SteadyBlock"

-- =============================================================================
-- Window / UI
-- =============================================================================
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_decorations = "RESIZE"
config.window_background_opacity = 1.0
config.enable_scroll_bar = false
config.scrollback_lines = 10000
config.check_for_updates = false

-- =============================================================================
-- Tab bar
-- =============================================================================
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false

-- =============================================================================
-- Keybindings: vim-style pane navigation + tab management
-- =============================================================================
config.keys = {
  -- Pane splitting
  { key = "d", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "e", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Pane navigation (vim-style)
  { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },

  -- Pane close
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },

  -- Tab management
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "[", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "]", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
}

return config
