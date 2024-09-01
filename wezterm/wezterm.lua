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
local function bind_super_key_to_vim(key)
  return {
    key = key,
    mods = "CMD",
    action = wezterm.action_callback(function(win, pane)
      local char = super_vim_keys_map[key]
      -- wezterm.:og_info("Triggered for key: " .. key .. ", char: " .. tostring(char))
      if char and is_vim(pane) then
        -- wezterm.log_info("Sending to Vim: " .. char)
        win:perform_action({
          SendKey = { key = char, mods = nil },
        }, pane)
      else
        -- Fall back to WezTerm pane navigation
        local direction = {
          h = "Left",
          j = "Down",
          k = "Up",
          l = "Right",
        }
        win:perform_action(wezterm.action.ActivatePaneDirection(direction[key]), pane)
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

config.enable_tab_bar = false
config.native_macos_fullscreen_mode = true

config.keys = {
  { mods = "CMD", key = "i",    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { mods = "CMD", key = "o",    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "h",    mods = "CMD", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "j",    mods = "CMD", action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "k",    mods = "CMD", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "l",    mods = "CMD", action = wezterm.action.ActivatePaneDirection("Right") },
  bind_super_key_to_vim("h"),
  bind_super_key_to_vim("j"),
  bind_super_key_to_vim("k"),
  bind_super_key_to_vim("l"),
}

return config
