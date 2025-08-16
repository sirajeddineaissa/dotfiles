local wezterm = require("wezterm")
local config = wezterm.config_builder()

local function get_colors_for_appearance(appearance)
	if appearance:find("Dark") then
		return {
			foreground = "#B5CFD4",
			background = "#1E222A",
			cursor_bg = "#ECEFF4",
			cursor_fg = "#1E222A",
			selection_bg = "#3B4252",
			selection_fg = "#ECEFF4",
			ansi = {
				"#3B4252", "#FF6E7B", "#00AD6C", "#FFE68B",
				"#81A1FF", "#D58AFF", "#AD00F0", "#ECEFF4",
			},
			brights = {
				"#4C566A", "#FF9BA6", "#C3FFA8", "#FFF0A3",
				"#A5B8FF", "#E2A3FF", "#A3FFEE", "#FFFFFF",
			},
			tab_bar = {
				background = "#1E222A",
				active_tab = {
					bg_color = "#ECEFF4",
					fg_color = "#1E222A",
					intensity = "Bold",
				},
				inactive_tab = {
					bg_color = "#3B4252",
					fg_color = "#B5CFD4",
				},
				inactive_tab_hover = {
					bg_color = "#434C5E",
					fg_color = "#ECEFF4",
				},
			},
		}
	else
		return {
			foreground = "#2E3440",
			background = "#FFFFFF",
			cursor_bg = "#2E3440",
			cursor_fg = "#FFFFFF",
			selection_bg = "#D8DEE9",
			selection_fg = "#2E3440",
			ansi = {
				"#2E3440", "#B02A37", "#7C9F32", "#C7923E",
				"#4F6F9F", "#9F5F8F", "#5F8F8F", "#D8DEE9",
			},
			brights = {
				"#3B4252", "#D32F2F", "#4CAF50", "#FF9800",
				"#2196F3", "#9C27B0", "#00BCD4", "#2E3440",
			},
			tab_bar = {
				background = "#FFFFFF",
				active_tab = {
					bg_color = "#2E3440",
					fg_color = "#FFFFFF",
					intensity = "Bold",
				},
				inactive_tab = {
					bg_color = "#E5E9F0",
					fg_color = "#3B4252",
				},
				inactive_tab_hover = {
					bg_color = "#D8DEE9",
					fg_color = "#2E3440",
				},
			},
		}
	end
end

-- Colors and appearance
config.color_scheme = nil
config.colors = get_colors_for_appearance(wezterm.gui.get_appearance())

-- Native macOS window with traffic light buttons
config.window_decorations = "RESIZE"
config.native_macos_fullscreen_mode = false

-- Window and UI
config.hide_tab_bar_if_only_one_tab = false
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.8 }

-- Font
config.font = wezterm.font_with_fallback({
	{ family = "JetBrains Mono", weight = "Medium" },
	{ family = "SF Mono", weight = "Medium" },
	{ family = "Noto Color Emoji" },
})
config.font_size = 14
config.line_height = 1.2

-- Terminal behavior
config.scrollback_lines = 50000
config.enable_scroll_bar = false
config.audible_bell = "Disabled"
config.window_close_confirmation = "NeverPrompt"

-- Tab bar
config.use_fancy_tab_bar = false
config.tab_max_width = 80
config.switch_to_last_active_tab_when_closing_tab = true

-- Key bindings
config.keys = {
	-- Pane splitting
	{ key = "|", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "_", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	
	-- Pane navigation
	{ key = "h", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Right") },
	
	-- Pane resizing
	{ key = "LeftArrow", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
	{ key = "DownArrow", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
	{ key = "UpArrow", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
	{ key = "RightArrow", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
	
	-- Tab management
	{ key = "t", mods = "CMD", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CMD", action = wezterm.action.CloseCurrentTab({ confirm = false }) },
	
	-- Utilities
	{ key = "k", mods = "CMD", action = wezterm.action.ClearScrollback("ScrollbackAndViewport") },
	{ key = "f", mods = "CTRL|CMD", action = wezterm.action.ToggleFullScreen },
	
	-- Font size
	{ key = "=", mods = "CMD", action = wezterm.action.IncreaseFontSize },
	{ key = "-", mods = "CMD", action = wezterm.action.DecreaseFontSize },
	{ key = "0", mods = "CMD", action = wezterm.action.ResetFontSize },
	
	-- Select all and copy
	{
		key = "a", mods = "CMD",
		action = wezterm.action_callback(function(window, pane)
			pane:select_text_range({ start_line = 0, end_line = pane:get_dimensions().scrollback_rows })
			window:perform_action(wezterm.action.CopyTo("Clipboard"), pane)
		end),
	},
}

-- Mouse bindings
config.mouse_bindings = {
	{ event = { Down = { streak = 2, button = "Left" } }, mods = "NONE", action = wezterm.action.SelectTextAtMouseCursor("Word") },
	{ event = { Down = { streak = 3, button = "Left" } }, mods = "NONE", action = wezterm.action.SelectTextAtMouseCursor("Line") },
}

return config
