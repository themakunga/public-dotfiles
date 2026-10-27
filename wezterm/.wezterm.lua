local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Aperture Science: play welcome jingle on GUI startup
wezterm.on("gui-startup", function()
	if wezterm.hostname() == "aperture-science" then
		local sound = wezterm.home_dir .. "/.local/share/sounds/aperture-welcome.wav"
		os.execute("mpv --no-video --really-quiet " .. sound .. " &")
	end
end)

config.font = wezterm.font("Hack Nerd Font")
config.font_size = 14
config.color_scheme = "Tokyo Night Storm"

local hostname = wezterm.hostname()
config.window_background_opacity = hostname == "aperture-science" and 0.85 or 1.0
config.native_macos_fullscreen_mode = false
config.window_padding = { left = "10pt", right = "10pt", top = "10pt", bottom = "10pt" }

config.tab_and_split_indices_are_zero_based = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- Spawn a screensaver alias in a right split
local function scr(alias)
	return act.SplitPane({
		direction = "Right",
		command = { args = { "zsh", "-i", "-c", alias } },
	})
end

config.keys = {
	{ key = "1", mods = "CTRL|ALT", action = scr("matrix") },
	{ key = "2", mods = "CTRL|ALT", action = scr("bonsai") },
	{ key = "3", mods = "CTRL|ALT", action = scr("pipes") },
	{ key = "4", mods = "CTRL|ALT", action = scr("nyan") },
	{ key = "q", mods = "CTRL|ALT", action = scr("funky") },
}

return config
