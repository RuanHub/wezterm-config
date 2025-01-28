local wezterm = require("wezterm")

local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

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

	-- Remove the domain name portion of the hostname
	local hostname = cwd_uri.host or wezterm.hostname()
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
	table.insert(cells, cwd_path)
	if git_branch then
		table.insert(cells, " " .. git_branch) -- Add a Git branch symbol
	end

	-- An entry for each battery (typically 0 or 1 battery)
	for _, b in ipairs(wezterm.battery_info()) do
		table.insert(cells, string.format("%.0f%%", b.state_of_charge * 100))
	end

	-- Color palette for the backgrounds of each cell (Neon Blue variant)
	local colors = {
		"#00FFFF", -- Neon Cyan/Blue
		"#00BFFF", -- Deep Sky Blue
		"#1E88E5", -- Blue
		"#42A5F5", -- Light Blue
		"#29B6F6", -- Sky Blue
	}

	-- Foreground color for the text across the fade
	local text_fg = "#ffffff" -- white for high contrast

	-- The elements to be formatted
	local elements = {}
	-- How many cells have been formatted
	local num_cells = 0

	-- Translate a cell into elements
	local function push(text, is_last)
		local cell_no = num_cells + 1
		table.insert(elements, { Foreground = { Color = text_fg } })
		table.insert(elements, { Background = { Color = colors[cell_no] } })
		table.insert(elements, { Text = " " .. text .. " " })
		if not is_last then
			table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
			table.insert(elements, { Text = SOLID_LEFT_ARROW })
		end
		num_cells = num_cells + 1
		--
	end

	while #cells > 0 do
		local cell = table.remove(cells, 1)
		push(cell, #cells == 0)
	end

	window:set_right_status(wezterm.format(elements))
end)

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local edge_background = "#0b0022"
	local background = "#1E88E5"
	local foreground = "#FFFFFF"

	if tab.is_active then
		background = "#00BFFF"
		foreground = "#FFFFFF"
	elseif hover then
		background = "#00FFFF"
		foreground = "#FFFFFF"
	end

	local edge_foreground = background

	local title = tab_title(tab)

	-- ensure that the titles fit in the available space,
	-- and that we have room for the edges.
	title = wezterm.truncate_right(title, max_width - 2)

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)
