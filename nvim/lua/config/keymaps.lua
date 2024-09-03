-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.opt.signcolumn = "yes"
vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>")
vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>")
vim.keymap.set("n", "<C-i>", ":vs<CR>")
vim.keymap.set("n", "<C-o>", ":sp<CR>")
vim.keymap.set("i", "jk", "<ESC>")
vim.keymap.set("i", "jj", "<ESC>")
vim.keymap.set("i", "kk", "<ESC>")
vim.keymap.set("n", "gp", ":pop<CR>")
vim.keymap.set("n", "go", ":bdelete<CR>")
vim.keymap.set("n", "-", ":Oil<CR>", { desc = "Open oil" })

--- configure shifting

vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true, silent = true })

-- open configuration
vim.keymap.set("n", "<leader>Lc", ":e $MYVIMRC<CR>", { noremap = true, silent = true, desc = "Open init.lua" })

--- resize pan

vim.keymap.set("n", "<A-l>", function()
	local win = vim.api.nvim_get_current_win()
	local width = vim.api.nvim_win_get_width(win)
	vim.api.nvim_win_set_width(win, width + 5)
end, { noremap = true, silent = true, desc = "Increase pane width" })

vim.keymap.set("n", "<A-h>", function()
	local win = vim.api.nvim_get_current_win()
	local width = vim.api.nvim_win_get_width(win)
	vim.api.nvim_win_set_width(win, width - 5)
end, { noremap = true, silent = true, desc = "Decrease pane width" })

vim.keymap.set("n", "<A-j>", function()
	local win = vim.api.nvim_get_current_win()
	local height = vim.api.nvim_win_get_height(win)
	vim.api.nvim_win_set_height(win, height + 5)
end, { noremap = true, silent = true, desc = "Increase pane height" })
vim.keymap.set("n", "<A-k>", function()
	local win = vim.api.nvim_get_current_win()
	local height = vim.api.nvim_win_get_height(win)
	vim.api.nvim_win_set_height(win, height - 5)
end, { noremap = true, silent = true, desc = "Decrease pane height" })
