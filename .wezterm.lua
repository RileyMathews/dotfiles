local wezterm = require("wezterm")
local config = wezterm.config_builder()
config.color_scheme = "Catppuccin Mocha"
config.enable_tab_bar = false
config.unicode_version = 14
-- config.font = wezterm.font("Hack Nerd Font")
return config
