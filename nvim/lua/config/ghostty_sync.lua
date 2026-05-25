---@type table
local vim = vim

-- ============================================================
-- Bidirectional theme sync between Neovim and Ghostty.
--
--   Ghostty → Neovim: VimEnter / BufWritePost / fs_poll watch
--                     ~/.config/ghostty/config and apply the
--                     mapped colorscheme.
--   Neovim → Ghostty: ColorScheme autocmd rewrites the active
--                     `theme = ` line and triggers Ghostty's
--                     reload (osascript on macOS, SIGUSR2 on
--                     Linux/GTK builds).
--
-- If ~/.config/ghostty/config doesn't exist, this module is a
-- silent no-op — no autocmds fire, no watcher is registered.
-- ============================================================

local ghostty_config = vim.fn.expand("~/.config/ghostty/config")
local ghostty_available = vim.uv.fs_stat(ghostty_config) ~= nil
local fallback_colorscheme = "gruvbox-material"

-- ============================================================
-- Concurrency / multi-nvim safety toggles.
--
-- atomic_write: write via tmp file + os.rename (POSIX atomic). Prevents
-- two nvims writing the config simultaneously from producing a corrupted
-- half-written file. Set false to fall back to direct vim.fn.writefile.
--
-- skip_own_writes: remember the last theme this nvim wrote and skip the
-- fs_poll re-apply if it matches (within own_write_ttl_ms). Without it,
-- nvim A picks "X" → writes file → A's own fs_poll fires → re-sources
-- the colorscheme (wasteful), and in the two-nvim case, A re-applies
-- whatever B wrote last even if A just picked. Set false to disable.
--
-- Set either to false to disable that protection independently.
-- ============================================================
local atomic_write = true
local skip_own_writes = true
local own_write_ttl_ms = 3000  -- how long to honor "we just wrote this"
local last_own_write = { theme = nil, ts = 0 }

-- Ghostty theme name → nvim colorscheme. String values run :colorscheme
-- directly; function values handle plugins where the variant is selected
-- via setup() or vim.o.background.
local theme_map = {
  -- Gruvbox Material (also aliasing the bare "Gruvbox" variants)
  ["Gruvbox Material"] = "gruvbox-material",
  ["Gruvbox Material Dark"] = "gruvbox-material",
  ["Gruvbox Material Light"] = "gruvbox-material",
  ["Gruvbox dark"] = "gruvbox-material",
  ["Gruvbox Dark"] = "gruvbox-material",
  ["Gruvbox Dark Hard"] = "gruvbox-material",
  ["Gruvbox Light"] = "gruvbox-material",
  ["Gruvbox Light Hard"] = "gruvbox-material",

  -- Catppuccin
  ["Catppuccin Mocha"] = "catppuccin-mocha",
  ["Catppuccin Macchiato"] = "catppuccin-macchiato",
  ["Catppuccin Frappe"] = "catppuccin-frappe",
  ["Catppuccin Latte"] = "catppuccin-latte",

  -- Tokyo Night
  ["TokyoNight"] = "tokyonight",
  ["TokyoNight Storm"] = "tokyonight-storm",
  ["TokyoNight Moon"] = "tokyonight-moon",
  ["TokyoNight Night"] = "tokyonight-night",
  ["TokyoNight Day"] = "tokyonight-day",

  -- Kanagawa
  ["Kanagawa Wave"] = "kanagawa-wave",
  ["Kanagawa Dragon"] = "kanagawa-dragon",
  ["Kanagawa Lotus"] = "kanagawa-lotus",

  -- Rose Pine
  ["Rose Pine"] = "rose-pine",
  ["Rose Pine Moon"] = "rose-pine-moon",
  ["Rose Pine Dawn"] = "rose-pine-dawn",

  -- Solarized
  ["Solarized Dark Higher Contrast"] = "solarized",
  ["Solarized Dark Patched"] = "solarized",
  ["iTerm2 Solarized Dark"] = "solarized",
  ["iTerm2 Solarized Light"] = function()
    pcall(require, "solarized")
    vim.o.background = "light"
    vim.cmd.colorscheme("solarized")
  end,

  -- Dracula
  ["Dracula"] = "dracula",
  ["Dracula+"] = "dracula",

  -- Nord
  ["Nord"] = "nord",

  -- OneDark (alias colorschemes in ~/.config/nvim/colors/ select the variant)
  ["Atom One Dark"] = "atom-one-dark",
  ["Atom One Light"] = "atom-one-light",

  -- Ayu
  ["Ayu"] = "ayu-dark",
  ["Ayu Light"] = "ayu-light",
  ["Ayu Mirage"] = "ayu-mirage",

  -- GitHub (require setup() to register the colorschemes)
  ["GitHub"] = function() require("github-theme").setup() vim.cmd.colorscheme("github_dark") end,
  ["GitHub Dark"] = function() require("github-theme").setup() vim.cmd.colorscheme("github_dark") end,
  ["GitHub Dark Default"] = function() require("github-theme").setup() vim.cmd.colorscheme("github_dark_default") end,
  ["GitHub Dark Dimmed"] = function() require("github-theme").setup() vim.cmd.colorscheme("github_dark_dimmed") end,
  ["GitHub Dark High Contrast"] = function() require("github-theme").setup() vim.cmd.colorscheme("github_dark_high_contrast") end,
  ["GitHub Dark Colorblind"] = function() require("github-theme").setup() vim.cmd.colorscheme("github_dark_colorblind") end,
  ["GitHub Light Default"] = function() require("github-theme").setup() vim.cmd.colorscheme("github_light_default") end,
  ["GitHub Light High Contrast"] = function() require("github-theme").setup() vim.cmd.colorscheme("github_light_high_contrast") end,
  ["GitHub Light Colorblind"] = function() require("github-theme").setup() vim.cmd.colorscheme("github_light_colorblind") end,

  -- Monokai Pro (filter set via setup)
  ["Monokai Pro"] = function() require("monokai-pro").setup({ filter = "pro" }) vim.cmd.colorscheme("monokai-pro") end,
  ["Monokai Pro Light"] = function() require("monokai-pro").setup({ filter = "light" }) vim.cmd.colorscheme("monokai-pro-light") end,
  ["Monokai Pro Machine"] = function() require("monokai-pro").setup({ filter = "machine" }) vim.cmd.colorscheme("monokai-pro") end,
  ["Monokai Pro Octagon"] = function() require("monokai-pro").setup({ filter = "octagon" }) vim.cmd.colorscheme("monokai-pro") end,
  ["Monokai Pro Ristretto"] = function() require("monokai-pro").setup({ filter = "ristretto" }) vim.cmd.colorscheme("monokai-pro") end,
  ["Monokai Pro Spectrum"] = function() require("monokai-pro").setup({ filter = "spectrum" }) vim.cmd.colorscheme("monokai-pro") end,
  ["Monokai Classic"] = function() require("monokai-pro").setup({ filter = "classic" }) vim.cmd.colorscheme("monokai-pro") end,

  -- Everforest (variant via global var)
  ["Everforest Dark Hard"] = function()
    vim.o.background = "dark"
    vim.g.everforest_background = "hard"
    vim.cmd.colorscheme("everforest")
  end,
  ["Everforest Light Med"] = function()
    vim.o.background = "light"
    vim.g.everforest_background = "medium"
    vim.cmd.colorscheme("everforest")
  end,

  -- Nightfox
  ["Nightfox"] = "nightfox",
  ["Dayfox"] = "dayfox",
  ["Dawnfox"] = "dawnfox",
  ["Duskfox"] = "duskfox",
  ["Nordfox"] = "nordfox",
  ["Terafox"] = "terafox",
  ["Carbonfox"] = "carbonfox",

  -- Zenbones
  ["Zenbones"] = "zenbones",
  ["Zenbones Dark"] = "zenbones",
  ["Zenbones Light"] = function()
    vim.o.background = "light"
    vim.cmd.colorscheme("zenbones")
  end,
  ["Zenwritten Dark"] = "zenwritten",
  ["Zenwritten Light"] = function()
    vim.o.background = "light"
    vim.cmd.colorscheme("zenwritten")
  end,
  ["Kanagawabones"] = "kanagawabones",
  ["Neobones Dark"] = "neobones",
  ["Neobones Light"] = function()
    vim.o.background = "light"
    vim.cmd.colorscheme("neobones")
  end,
  ["Vimbones"] = "vimbones",
  ["Seoulbones Dark"] = "seoulbones",
  ["Seoulbones Light"] = function()
    vim.o.background = "light"
    vim.cmd.colorscheme("seoulbones")
  end,
  ["Duckbones"] = "duckbones",
  ["Zenburned"] = "zenburned",

  -- Sonokai
  ["Sonokai"] = "sonokai",

  -- Oxocarbon
  ["Oxocarbon"] = "oxocarbon",

  -- Onenord (light shipped as separate colorscheme)
  ["Onenord"] = "onenord",
  ["Onenord Light"] = "onenord-light",

  -- Melange (variant via background; require() forces lazy-load)
  ["Melange Dark"] = function()
    pcall(require, "melange")
    vim.o.background = "dark"
    vim.cmd.colorscheme("melange")
  end,
  ["Melange Light"] = function()
    pcall(require, "melange")
    vim.o.background = "light"
    vim.cmd.colorscheme("melange")
  end,

  -- Material (each Ghostty variant maps to material.nvim's colorscheme name)
  ["Material"] = "material",
  ["Material Dark"] = "material-darker",
  ["Material Darker"] = "material-darker",
  ["Material Ocean"] = "material-oceanic",
  ["Material Design Colors"] = "material",

  -- Modus (Tinted variant set via setup({ variant = "tinted" }))
  ["Modus Operandi"] = "modus_operandi",
  ["Modus Vivendi"] = "modus_vivendi",
  ["Modus Operandi Tinted"] = function()
    require("modus-themes").setup({ variant = "tinted" })
    vim.cmd.colorscheme("modus_operandi")
  end,
  ["Modus Vivendi Tinted"] = function()
    require("modus-themes").setup({ variant = "tinted" })
    vim.cmd.colorscheme("modus_vivendi")
  end,

  -- Doom One
  ["Doom One"] = "doom-one",

  -- Poimandres
  ["Poimandres"] = "poimandres",

  -- Bluloco
  ["Bluloco Dark"] = "bluloco-dark",
  ["Bluloco Light"] = "bluloco-light",

  -- Flexoki (uses explicit suffix names; require() forces lazy-load)
  ["Flexoki Dark"] = function()
    pcall(require, "flexoki")
    vim.o.background = "dark"
    vim.cmd.colorscheme("flexoki-dark")
  end,
  ["Flexoki Light"] = function()
    pcall(require, "flexoki")
    vim.o.background = "light"
    vim.cmd.colorscheme("flexoki-light")
  end,

  -- Vague
  ["Vague"] = "vague",

  -- Vesper
  ["Vesper"] = "vesper",

  -- Night Owl
  ["Night Owl"] = "night-owl",

  -- Adwaita (background-aware; require() forces lazy-load)
  ["Adwaita"] = function()
    pcall(require, "adwaita")
    vim.o.background = "light"
    vim.cmd.colorscheme("adwaita")
  end,
  ["Adwaita Dark"] = function()
    pcall(require, "adwaita")
    vim.o.background = "dark"
    vim.cmd.colorscheme("adwaita")
  end,

  -- Moonfly
  ["Moonfly"] = "moonfly",

  -- No Clown Fiesta
  ["No Clown Fiesta"] = "no-clown-fiesta",
}

-- Reverse map: nvim colorscheme name → preferred Ghostty theme name.
-- Function values pick the right Ghostty variant from vim.o.background.
-- Guard flag prevents the loop: ColorScheme autocmd writes file → fs_poll
-- fires → apply_ghostty_theme re-applies → ColorScheme would write again.
local applying_from_ghostty = false
local nvim_to_ghostty = {
  ["gruvbox-material"] = "Gruvbox dark",
  ["catppuccin"] = "Catppuccin Mocha",
  ["catppuccin-mocha"] = "Catppuccin Mocha",
  ["catppuccin-frappe"] = "Catppuccin Frappe",
  ["catppuccin-macchiato"] = "Catppuccin Macchiato",
  ["catppuccin-latte"] = "Catppuccin Latte",
  ["tokyonight"] = "TokyoNight",
  ["tokyonight-storm"] = "TokyoNight Storm",
  ["tokyonight-moon"] = "TokyoNight Moon",
  ["tokyonight-night"] = "TokyoNight Night",
  ["tokyonight-day"] = "TokyoNight Day",
  ["kanagawa"] = "Kanagawa Wave",
  ["kanagawa-wave"] = "Kanagawa Wave",
  ["kanagawa-dragon"] = "Kanagawa Dragon",
  ["kanagawa-lotus"] = "Kanagawa Lotus",
  ["rose-pine"] = "Rose Pine",
  ["rose-pine-moon"] = "Rose Pine Moon",
  ["rose-pine-dawn"] = "Rose Pine Dawn",
  ["solarized"] = "Solarized Dark Higher Contrast",
  ["dracula"] = "Dracula",
  ["nord"] = "Nord",
  ["onedark"] = "Atom One Dark",
  ["atom-one-dark"] = "Atom One Dark",
  ["atom-one-light"] = "Atom One Light",
  ["ayu"] = "Ayu",
  ["ayu-dark"] = "Ayu",
  ["ayu-light"] = "Ayu Light",
  ["ayu-mirage"] = "Ayu Mirage",
  ["github_dark"] = "GitHub Dark",
  ["github_dark_default"] = "GitHub Dark Default",
  ["github_dark_dimmed"] = "GitHub Dark Dimmed",
  ["github_dark_high_contrast"] = "GitHub Dark High Contrast",
  ["github_dark_colorblind"] = "GitHub Dark Colorblind",
  ["github_light_default"] = "GitHub Light Default",
  ["github_light_high_contrast"] = "GitHub Light High Contrast",
  ["github_light_colorblind"] = "GitHub Light Colorblind",
  ["monokai-pro"] = "Monokai Pro",
  ["monokai-pro-light"] = "Monokai Pro Light",
  ["monokai-pro-machine"] = "Monokai Pro Machine",
  ["monokai-pro-octagon"] = "Monokai Pro Octagon",
  ["monokai-pro-ristretto"] = "Monokai Pro Ristretto",
  ["monokai-pro-spectrum"] = "Monokai Pro Spectrum",
  ["monokai-pro-classic"] = "Monokai Classic",
  ["everforest"] = function()
    return vim.o.background == "light" and "Everforest Light Med" or "Everforest Dark Hard"
  end,
  ["nightfox"] = "Nightfox",
  ["dayfox"] = "Dayfox",
  ["dawnfox"] = "Dawnfox",
  ["duskfox"] = "Duskfox",
  ["nordfox"] = "Nordfox",
  ["terafox"] = "Terafox",
  ["carbonfox"] = "Carbonfox",
  ["zenbones"] = function()
    return vim.o.background == "light" and "Zenbones Light" or "Zenbones Dark"
  end,
  ["zenwritten"] = function()
    return vim.o.background == "light" and "Zenwritten Light" or "Zenwritten Dark"
  end,
  ["kanagawabones"] = "Kanagawabones",
  ["neobones"] = function()
    return vim.o.background == "light" and "Neobones Light" or "Neobones Dark"
  end,
  ["vimbones"] = "Vimbones",
  ["seoulbones"] = function()
    return vim.o.background == "light" and "Seoulbones Light" or "Seoulbones Dark"
  end,
  ["duckbones"] = "Duckbones",
  ["zenburned"] = "Zenburned",
  ["sonokai"] = "Sonokai",
  ["oxocarbon"] = "Oxocarbon",
  ["onenord"] = "Onenord",
  ["onenord-light"] = "Onenord Light",
  ["melange"] = function()
    return vim.o.background == "light" and "Melange Light" or "Melange Dark"
  end,
  ["material"] = "Material",
  ["material-darker"] = "Material Darker",
  ["material-lighter"] = "Material",
  ["material-oceanic"] = "Material Ocean",
  ["material-palenight"] = "Material Dark",
  ["material-deep-ocean"] = "Material Ocean",
  ["modus_operandi"] = "Modus Operandi",
  ["modus_vivendi"] = "Modus Vivendi",
  ["modus_operandi_tinted"] = "Modus Operandi Tinted",
  ["modus_vivendi_tinted"] = "Modus Vivendi Tinted",
  ["doom-one"] = "Doom One",
  ["poimandres"] = "Poimandres",
  ["bluloco-dark"] = "Bluloco Dark",
  ["bluloco-light"] = "Bluloco Light",
  ["flexoki"] = function()
    return vim.o.background == "light" and "Flexoki Light" or "Flexoki Dark"
  end,
  ["flexoki-dark"] = "Flexoki Dark",
  ["flexoki-light"] = "Flexoki Light",
  ["vague"] = "Vague",
  ["vesper"] = "Vesper",
  ["night-owl"] = "Night Owl",
  ["adwaita"] = function()
    return vim.o.background == "light" and "Adwaita" or "Adwaita Dark"
  end,
  ["moonfly"] = "Moonfly",
  ["no-clown-fiesta"] = "No Clown Fiesta",
}

local function resolve_ghostty_name(nvim_scheme)
  local entry = nvim_to_ghostty[nvim_scheme]
  if type(entry) == "function" then
    local ok, name = pcall(entry)
    return ok and name or nil
  end
  return entry
end

-- Last non-commented `theme = X` wins, mirroring Ghostty's own parse order.
local function read_ghostty_theme()
  local ok, lines = pcall(vim.fn.readfile, ghostty_config)
  if not ok or type(lines) ~= "table" then return nil end
  local theme
  for _, line in ipairs(lines) do
    local stripped = line:gsub("^%s+", "")
    if not stripped:match("^#") then
      local value = stripped:match("^theme%s*=%s*(.-)%s*$")
      if value and value ~= "" then
        theme = value
      end
    end
  end
  return theme
end

-- Atomic write helper: writes via tmp file + rename so a concurrent reader
-- (Ghostty's reload, another nvim's fs_poll) never sees a half-written file.
-- POSIX rename(2) is atomic on the same filesystem. Falls back to direct
-- writefile if atomic_write is disabled.
local function write_config_lines(lines)
  if not atomic_write then
    return pcall(vim.fn.writefile, lines, ghostty_config)
  end
  local tmp = ghostty_config .. ".nvim-sync.tmp"
  local ok = pcall(vim.fn.writefile, lines, tmp)
  if not ok then
    pcall(os.remove, tmp)
    return false
  end
  local renamed, err = os.rename(tmp, ghostty_config)
  if not renamed then
    pcall(os.remove, tmp)
    vim.notify("[ghostty-sync] atomic rename failed: " .. tostring(err), vim.log.levels.WARN)
    return false
  end
  return true
end

-- Rewrite the active `theme = X` line in ghostty_config (last non-commented
-- one wins). If no active line exists, append. Returns true if file changed.
local function set_ghostty_theme(ghostty_name)
  local ok, lines = pcall(vim.fn.readfile, ghostty_config)
  if not ok or type(lines) ~= "table" then return false end
  local last_active_idx
  for i, line in ipairs(lines) do
    local stripped = line:gsub("^%s+", "")
    if not stripped:match("^#") and stripped:match("^theme%s*=") then
      last_active_idx = i
    end
  end
  local new_line = "theme = " .. ghostty_name
  if last_active_idx and lines[last_active_idx] == new_line then
    return false
  end
  if last_active_idx then
    lines[last_active_idx] = new_line
  else
    table.insert(lines, new_line)
  end
  if not write_config_lines(lines) then return false end
  -- Record our own write so fs_poll can skip the redundant re-apply
  -- (and avoid clobbering this user's pick if another nvim wrote first).
  last_own_write = { theme = ghostty_name, ts = vim.uv.now() }
  return true
end

local function apply_ghostty_theme()
  if not ghostty_available then return end
  applying_from_ghostty = true
  local ghostty_theme = read_ghostty_theme()
  local mapped = ghostty_theme and theme_map[ghostty_theme]
  local function done()
    applying_from_ghostty = false
  end
  if type(mapped) == "function" then
    local ok, err = pcall(mapped)
    done()
    if ok then return end
    vim.notify("Ghostty theme apply failed (" .. tostring(ghostty_theme) .. "): " .. tostring(err), vim.log.levels.WARN)
  elseif type(mapped) == "string" then
    local ok, err = pcall(vim.cmd.colorscheme, mapped)
    done()
    if ok then return end
    vim.notify("Colorscheme " .. mapped .. " failed: " .. tostring(err), vim.log.levels.WARN)
  elseif ghostty_theme then
    done()
    vim.notify("No mapping for Ghostty theme: " .. ghostty_theme .. " — using fallback", vim.log.levels.INFO)
  else
    done()
  end
  applying_from_ghostty = true
  pcall(vim.cmd.colorscheme, fallback_colorscheme)
  applying_from_ghostty = false
end

-- Trigger Ghostty's "Reload Configuration" externally. Picks the right path
-- per OS: SIGUSR2 is the canonical signal but only the GTK build handles it
-- (per Ghostty 1.2.0 release notes); on macOS we click the menu item via
-- osascript, which requires Accessibility permission for the parent process.
local function trigger_ghostty_reload()
  if vim.fn.has("mac") == 1 then
    vim.system({
      "osascript", "-e",
      [[tell application "System Events" to tell process "Ghostty" to click menu item "Reload Configuration" of menu "Ghostty" of menu bar item "Ghostty" of menu bar 1]],
    }, { detach = true })
  else
    vim.system({ "pkill", "-SIGUSR2", "ghostty" }, { detach = true })
  end
end

-- Apply the Ghostty-side theme on nvim startup so they begin in sync.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = apply_ghostty_theme,
})

-- BufWritePost: instant trigger when ghostty/config is saved from inside nvim.
-- More reliable than fs_poll for the common case (atomic-save semantics).
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function(args)
    if vim.fn.fnamemodify(args.file, ":p") == ghostty_config then
      vim.notify("[ghostty-sync] BufWritePost → applying", vim.log.levels.INFO)
      apply_ghostty_theme()
      trigger_ghostty_reload()
    end
  end,
})

-- ColorScheme → Ghostty: when nvim swaps colorscheme (e.g. via :colorscheme,
-- :FzfLua colorschemes), rewrite the active theme line in ghostty_config and
-- trigger Ghostty reload. Guard skips when we're applying inbound from Ghostty.
-- Debounced 150ms so rapid back-to-back events (FzfLua picker's on_close
-- revert + fn_selected re-apply) collapse into one final write+reload —
-- otherwise intermediate states race the async osascript reload.
local pending_ghostty_name
local debounce_timer = vim.uv.new_timer()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function(args)
    if not ghostty_available then return end
    if applying_from_ghostty then return end
    local ghostty_name = resolve_ghostty_name(args.match)
    if not ghostty_name then return end
    pending_ghostty_name = ghostty_name
    debounce_timer:stop()
    debounce_timer:start(150, 0, vim.schedule_wrap(function()
      local target = pending_ghostty_name
      pending_ghostty_name = nil
      if not target then return end
      if read_ghostty_theme() == target then return end
      if set_ghostty_theme(target) then
        vim.notify("[ghostty-sync] nvim → Ghostty: " .. target, vim.log.levels.INFO)
        trigger_ghostty_reload()
      end
    end))
  end,
})

-- Live-reload: poll the config file every 2s so atomic-save edits
-- (which break inode-based fs_event) still trigger a re-apply.
-- _G ref keeps the userdata alive past this module's load (avoids GC).
if ghostty_available then
  local watcher = vim.uv.new_fs_poll()
  _G.__ghostty_theme_watcher = watcher
  if watcher then
    watcher:start(ghostty_config, 2000, vim.schedule_wrap(function(err)
      if err then
        vim.notify("[ghostty-sync] poll error: " .. tostring(err), vim.log.levels.WARN)
        return
      end
      local detected = read_ghostty_theme() or "<none>"
      -- Skip if the change is just our own recent write echoing back via
      -- the poller. Without this, every outbound write costs a wasted
      -- :colorscheme re-source, and in the multi-nvim case it can clobber
      -- this user's just-made pick with whatever another nvim wrote.
      if skip_own_writes
          and last_own_write.theme == detected
          and (vim.uv.now() - last_own_write.ts) < own_write_ttl_ms then
        return
      end
      vim.notify("[ghostty-sync] config changed → " .. detected, vim.log.levels.INFO)
      apply_ghostty_theme()
      trigger_ghostty_reload()
    end))
  else
    vim.notify("[ghostty-sync] failed to create fs_poll watcher", vim.log.levels.WARN)
  end
end
