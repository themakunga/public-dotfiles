local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("Hack Nerd Font")
config.font_size = 14
config.color_scheme = "Tokyo Night Storm"

config.window_background_opacity = 1.0
config.native_macos_fullscreen_mode = false
config.window_padding = { left = "10pt", right = "10pt", top = "10pt", bottom = "10pt" }

config.tab_and_split_indices_are_zero_based = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

return config
