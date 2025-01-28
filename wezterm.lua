-- Pull in the wezterm API
local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local mux = wezterm.mux
local config = wezterm.config_builder()

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- Use PowerShell as default terminal
config.default_prog = { "pwsh.exe" }
-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "Adventure"

config.keys = {
	-- CTRL-SHIFT-p activates the debug overlay
	{ key = "P", mods = "CTRL", action = wezterm.action.ShowDebugOverlay },
}

tabline.setup({
	options = {
		icons_enabled = true,
		theme = "Cyberdyne",
		tabs_enabled = true,
		theme_overrides = {},
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		tabline_a = { "mode" },
		tabline_b = { "workspace" },
		tabline_c = { " " },
		tab_active = {
			"index",
			{ "parent", padding = 0 },
			"/",
			{ "cwd", padding = { left = 0, right = 1 } },
			{ "zoomed", padding = 0 },
		},
		tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
		tabline_x = { "ram", "cpu" },
		tabline_y = { "datetime", "battery" },
		tabline_z = { "domain" },
	},
	extensions = {},
})

config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 12
config.use_fancy_tab_bar = false

config.window_decorations = "RESIZE"

tabline.apply_to_config(config)

return config
