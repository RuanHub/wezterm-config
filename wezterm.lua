-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- This will hold the configuration.
local config = wezterm.config_builder()

wezterm.on("update-right-status", function(window, pane)
	-- Each element holds the text for a cell in a "powerline" style << fade
	local cells = {}

	-- Figure out the cwd and host of the current pane.
	-- This will pick up the hostname for the remote host if your
	-- shell is using OSC 7 on the remote host.
	local cwd_uri = pane:get_current_working_dir()
	local cwd_path = nil
	if wezterm.target_triple == "x86_64-pc-windows-msvc" then
		-- We are running on Windows remove the leading "/" char from the path
		cwd_path = cwd_uri.file_path:gsub("^/", "")
	else
		cwd_path = cwd_uri.file_path
	end

	if type(cwd_uri) == "userdata" then
		cwd = cwd_path
		hostname = cwd_uri.host or wezterm.hostname()
	end

	-- Remove the domain name portion of the hostname
	local dot = hostname:find("[.]")
	if dot then
		hostname = hostname:sub(1, dot - 1)
	end
	if hostname == "" then
		hostname = wezterm.hostname()
	end

	-- Get the current Git branch, if available
	local git_branch = nil
	if cwd_path then
		local git_cmd = { "git", "-C", cwd_path, "rev-parse", "--abbrev-ref", "HEAD" }
		local success, stdout, stderr = wezterm.run_child_process(git_cmd)
		if success and stdout and stdout:match("%S") then
			git_branch = stdout:gsub("%s+", "")
		end
	end

	table.insert(cells, hostname)
	table.insert(cells, cwd)
	if git_branch then
		table.insert(cells, " " .. git_branch) -- Add a Git branch symbol
	end

	-- Get the current Git branch, if available
	local git_branch = nil
	if cwd_path then
		local git_cmd = { "git", "-C", cwd_path, "rev-parse", "--abbrev-ref", "HEAD" }
		local success, stdout, stderr = wezterm.run_child_process(git_cmd)
		if success and stdout and stdout:match("%S") then
			git_branch = stdout:gsub("%s+", "")
		end
	end

	-- An entry for each battery (typically 0 or 1 battery)
	for _, b in ipairs(wezterm.battery_info()) do
		table.insert(cells, string.format("%.0f%%", b.state_of_charge * 100))
	end

	-- The powerline < symbol
	local LEFT_ARROW = utf8.char(0xe0b3)
	-- The filled in variant of the < symbol
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

	-- Color palette for the backgrounds of each cell
	local colors = {
		"#3c1361",
		"#52307c",
		"#663a82",
		"#7c5295",
		"#b491c8",
	}

	-- Foreground color for the text across the fade
	local text_fg = "#c0c0c0"

	-- The elements to be formatted
	local elements = {}
	-- How many cells have been formatted
	local num_cells = 0

	-- Translate a cell into elements
	function push(text, is_last)
		local cell_no = num_cells + 1
		table.insert(elements, { Foreground = { Color = text_fg } })
		table.insert(elements, { Background = { Color = colors[cell_no] } })
		table.insert(elements, { Text = " " .. text .. " " })
		if not is_last then
			table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
			table.insert(elements, { Text = SOLID_LEFT_ARROW })
		end
		num_cells = num_cells + 1
	end

	while #cells > 0 do
		local cell = table.remove(cells, 1)
		push(cell, #cells == 0)
	end

	window:set_right_status(wezterm.format(elements))
end)

-- Use PowerShell as default terminal
config.default_prog = { "pwsh.exe" }
-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = "AdventureTime"
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 12

config.use_fancy_tab_bar = false

-- config.enable_tab_bar = false
config.window_decorations = "RESIZE"
-- and finally, return the configuration to wezterm

return config
