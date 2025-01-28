-- Pull in the wezterm API
local wezterm = require("wezterm")
require("tab_bar")
local mux = wezterm.mux

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- This will hold the configuration.
local config = wezterm.config_builder()
config.status_update_interval = 1000

-- Use PowerShell as default terminal
config.default_prog = { "pwsh.exe" }
-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "Adventure"
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 12

config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"

-- and finally, return the configuration to wezterm
return config
