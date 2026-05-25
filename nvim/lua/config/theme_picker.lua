---@type table
local vim = vim

vim.api.nvim_create_user_command("Themes", function()
  require("fzf-lua").colorschemes()
end, { desc = "Pick a colorscheme (all installed)" })

vim.keymap.set("n", "<leader>tt", "<cmd>Themes<cr>", { desc = "Theme picker" })
