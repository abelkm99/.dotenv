local wezterm = require("wezterm")

local function is_vim(pane)
	local is_vim_env = pane:get_user_vars().IS_NVIM == "true"
	if is_vim_env == true then
		return true
	end
	-- This gsub is equivalent to POSIX basename(3)
	-- Given "/foo/bar" returns "bar"
	-- Given "c:\\foo\\bar" returns "bar"
	local process_name = string.gsub(pane:get_foreground_process_name(), "(.*[/\\])(.*)", "%2")
	return process_name == "nvim" or process_name == "vim"
end

local super_vim_keys_map = {
	h = utf8.char(0xB0),
	j = utf8.char(0xB1),
	k = utf8.char(0xB2),
	l = utf8.char(0xB3),
}

local super_vim_keys_map_alt = {
	h = utf8.char(0x2591),
	j = utf8.char(0x2592),
	k = utf8.char(0x2593),
	l = utf8.char(0x2588),
}
local direction = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function bind_super_key_to_vim(key, mods)
	return {
		key = key,
		mods = mods,
		action = wezterm.action_callback(function(win, pane)
			if mods == "CMD" then
				local char = super_vim_keys_map[key]
				-- wezterm.:og_info("Triggered for key: " .. key .. ", char: " .. tostring(char))
				if char and is_vim(pane) then
					-- wezterm.log_info("Sending to Vim: " .. char)
					win:perform_action({
						SendKey = { key = char, mods = nil },
					}, pane)
				else
					win:perform_action(wezterm.action.ActivatePaneDirection(direction[key]), pane)
				end
			end
			if mods == "ALT" then
				local char = super_vim_keys_map_alt[key]
				if char and is_vim(pane) then
					wezterm.log_info("Sending to Vim: " .. char)
					win:perform_action({
						SendKey = { key = char, mods = nil },
					}, pane)
				else
					win:perform_action(wezterm.action.AdjustPaneSize({ direction[key], 5 }), pane)
				end
			end
		end),
	}
end

local config = wezterm.config_builder()

config.color_scheme = "Gruvbox dark, medium (base16)"
config.color_scheme = "Gruvbox dark, hard (base16)"
config.color_scheme = "Gruvbox dark, medium (base16)"
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 14.0

config.window_background_opacity = 0.93
config.macos_window_background_blur = 12
config.native_macos_fullscreen_mode = false -- this will use custom fullscreen mode

config.enable_tab_bar = false

config.keys = {
	{ mods = "CMD", key = "i", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ mods = "CMD", key = "o", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- { key = "h",    mods = "CMD", action = wezterm.action.ActivatePaneDirection("Left") },
	-- { key = "j",    mods = "CMD", action = wezterm.action.ActivatePaneDirection("Down") },
	-- { key = "k",    mods = "CMD", action = wezterm.action.ActivatePaneDirection("Up") },
	-- { key = "l",    mods = "CMD", action = wezterm.action.ActivatePaneDirection("Right") },
	-- { key = "h",     mods = "ALT",  action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },

	bind_super_key_to_vim("h", "CMD"),
	bind_super_key_to_vim("j", "CMD"),
	bind_super_key_to_vim("k", "CMD"),
	bind_super_key_to_vim("l", "CMD"),
	bind_super_key_to_vim("h", "ALT"),
	bind_super_key_to_vim("j", "ALT"),
	bind_super_key_to_vim("k", "ALT"),
	bind_super_key_to_vim("l", "ALT"),
	{ key = "Enter", mods = "CMD",  action = wezterm.action.ToggleFullScreen },
	{ key = "v",     mods = "CMD",  action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "n",     mods = "CTRL", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
}

config.selection_word_boundary = " \t\n{}[]()\"'`,;:"

return config
