---@type table
local vim = vim

-- ============================================================
-- Neovide-only settings and keymaps.
--
-- Neovide is a GUI, so terminal keybinds (Ghostty, wezterm)
-- never reach it — the bindings below reproduce them.
--
-- macOS uses Cmd (<D-...>); Linux has no logo-key forwarding by
-- default, so the same actions sit on Ctrl there. Anything that
-- shells out to osascript is macOS-only.
--
-- No-op outside Neovide: setup() returns immediately when
-- g:neovide is unset, so terminal nvim on either OS is untouched.
-- ============================================================

local M = {}

local ZOOM_STEP = 1.10
local ALL_MODES = { "n", "i", "v", "t" }

local is_mac = vim.fn.has("macunix") == 1

-- macOS: Neovide's own AppleScript helper, used to focus a native
-- tab by index (Neovide only ships prev/next hotkeys itself).
local select_tab_script = vim.fn.expand("~/.config/neovide/select-tab.applescript")

local function scale_by(delta)
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end

local function setup_options()
	vim.g.neovide_scale_factor = 1.0

	if is_mac then
		-- Without this, Option emits ˙∆˚¬ instead of Meta, so <A-hjkl> never fires.
		vim.g.neovide_input_macos_option_key_is_meta = "both"
	end
end

local function setup_zoom(mod)
	vim.keymap.set(ALL_MODES, "<" .. mod .. "-=>", function() scale_by(ZOOM_STEP) end,
		{ silent = true, desc = "Zoom in" })
	vim.keymap.set(ALL_MODES, "<" .. mod .. "-->", function() scale_by(1 / ZOOM_STEP) end,
		{ silent = true, desc = "Zoom out" })
	vim.keymap.set(ALL_MODES, "<" .. mod .. "-0>", function() vim.g.neovide_scale_factor = 1.0 end,
		{ silent = true, desc = "Reset zoom" })
end

local function setup_fullscreen(mod)
	vim.keymap.set(ALL_MODES, "<" .. mod .. "-CR>", function()
		vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
	end, { silent = true, desc = "Toggle fullscreen" })
end

-- Neovide does not wire Cmd+C / Cmd+V to the system clipboard itself.
local function setup_clipboard()
	vim.keymap.set({ "n", "v" }, "<D-c>", '"+y', { desc = "Copy to system clipboard" })
	vim.keymap.set({ "n", "v" }, "<D-v>", '"+p', { desc = "Paste from system clipboard" })
	vim.keymap.set("i", "<D-v>", "<C-r>+", { desc = "Paste from system clipboard" })
	vim.keymap.set("c", "<D-v>", "<C-r>+", { silent = false, desc = "Paste from system clipboard" })
	vim.keymap.set("t", "<D-v>", '<C-\\><C-n>"+pi', { desc = "Paste from system clipboard" })
end

-- Jumping to a specific native tab is driven through the window's
-- accessibility tab bar, which means Accessibility permission for Neovide.
local function setup_native_tabs()
	if vim.fn.executable("osascript") ~= 1 then
		return
	end

	for i = 1, 9 do
		vim.keymap.set(ALL_MODES, "<D-" .. i .. ">", function()
			vim.system({ "osascript", select_tab_script, tostring(i) }, { text = true }, function(res)
				local out = vim.trim((res.stdout or "") .. (res.stderr or ""))
				if res.code ~= 0 or not out:match("^ok") then
					vim.schedule(function()
						vim.notify("tab " .. i .. ": " .. out, vim.log.levels.WARN)
					end)
				end
			end)
		end, { silent = true, desc = "Focus native tab " .. i })
	end
end

-- Ghostty rewrites super/ctrl + hjkl into ± ² ³ µ for Navigator.nvim
-- (see lua/plugins/navigations.lua). Call Navigator directly instead.
local function setup_navigation(mods)
	local nav_cmds = {
		h = "NavigatorLeft",
		j = "NavigatorDown",
		k = "NavigatorUp",
		l = "NavigatorRight",
	}

	for key, cmd in pairs(nav_cmds) do
		local rhs = "<Cmd>" .. cmd .. "<CR>"
		for _, mod in ipairs(mods) do
			vim.keymap.set({ "n", "t" }, "<" .. mod .. "-" .. key .. ">", rhs,
				{ silent = true, desc = cmd })
		end
	end
end

function M.setup()
	if not vim.g.neovide then
		return
	end

	setup_options()

	if is_mac then
		setup_zoom("D")
		setup_fullscreen("D")
		setup_clipboard()
		setup_native_tabs()
		setup_navigation({ "D", "C" })
	else
		setup_zoom("C")
		setup_fullscreen("C")
		setup_navigation({ "C" })
	end
end

return M
