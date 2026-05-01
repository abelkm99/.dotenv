---@type table
local vim = vim

-- Curated short-list of colorschemes for quick browsing. FzfLua's full
-- colorschemes picker shows 130+ entries; this is the ~20 you actually use.
-- Edit the list to taste.
local curated = {
  -- Dark
  "gruvbox-material",
  "catppuccin-mocha",
  "catppuccin-macchiato",
  "catppuccin-frappe",
  "tokyonight-moon",
  "tokyonight-storm",
  "tokyonight-night",
  "kanagawa-wave",
  "kanagawa-dragon",
  "rose-pine",
  "rose-pine-moon",
  "duskfox",
  "carbonfox",
  "nightfox",
  "atom-one-dark",
  "dracula",
  "nord",
  -- Light
  "catppuccin-latte",
  "tokyonight-day",
  "atom-one-light",
  "rose-pine-dawn",
  "kanagawa-lotus",
  "dawnfox",
}

vim.api.nvim_create_user_command("Themes", function()
  require("fzf-lua").colorschemes({ colors = curated })
end, { desc = "Pick from curated theme list" })

vim.keymap.set("n", "<leader>tt", "<cmd>Themes<cr>", { desc = "Theme picker (curated)" })
