vim.keymap.set("n", "<C-t>", function()
  local buf_id = vim.api.nvim_get_current_buf()
  print("buff", buf_id , "win", vim.api.nvim_get_current_win(),"buff_name", vim.api.nvim_buf_get_name(buf_id))
  -- vim.api.nvim_set_current_buf(14)
end)

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set({"n"}, "cp", function()
  local buf = vim.api.nvim_get_current_buf()
  local full = vim.api.nvim_buf_get_name(buf)

  if full == "" then
    print("No file name for this buffer")
    return
  end

  -- ":." makes the path relative to Neovim's current working directory (:pwd)
  local rel = vim.fn.fnamemodify(full, ":.")
  vim.fn.setreg("+", rel)
  print("Copied to clipboard: " .. rel)
end, { desc = "Copy current file path to clipboard" })


vim.keymap.set("v", "cP", function()
  local buf = vim.api.nvim_get_current_buf()
  local full = vim.api.nvim_buf_get_name(buf)

  if full == "" then
    print("No file name for this buffer")
    return
  end

  -- Path relative to Neovim's current working directory (:pwd)
  local rel = vim.fn.fnamemodify(full, ":.")

  -- Visual selection line range (works for v/V)
  local start_line = vim.fn.line("'<")
  local end_line   = vim.fn.line("'>")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local out = string.format("%s#L%d-%d", rel, start_line, end_line)
  vim.fn.setreg("+", out)
  print("Copied to clipboard: " .. out)
end, { desc = "Copy path#Lstart-end for visual selection" })

-- go out  of terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<c-\\><c-n>")

-- auto source files when they are saved
vim.keymap.set("n", "<leader><leader>x", ":source %<CR>", { desc = "Source current file" })
vim.keymap.set("n", "<leader>x", ":.lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

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

vim.api.nvim_set_keymap("v", ">", ">gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<", "<gv", { noremap = true, silent = true })

-- open configuration
vim.keymap.set("n", "<leader>Lc", ":e $MYVIMRC<CR>", { noremap = true, silent = true, desc = "Open init.lua" })

--- resize pan

vim.keymap.set({"n","t"}, "<A-l>", function()
	local win = vim.api.nvim_get_current_win()
	local width = vim.api.nvim_win_get_width(win)
	vim.api.nvim_win_set_width(win, width + 5)
end, { noremap = true, silent = true, desc = "Increase pane width" })

vim.keymap.set({"n","t"}, "<A-h>", function()
	local win = vim.api.nvim_get_current_win()
	local width = vim.api.nvim_win_get_width(win)
	vim.api.nvim_win_set_width(win, width - 5)
end, { noremap = true, silent = true, desc = "Decrease pane width" })

vim.keymap.set({"n","t"}, "<A-j>", function()
	local win = vim.api.nvim_get_current_win()
	local height = vim.api.nvim_win_get_height(win)
	vim.api.nvim_win_set_height(win, height + 5)
end, { noremap = true, silent = true, desc = "Increase pane height" })

vim.keymap.set({"n","t"}, "<A-k>", function()
	local win = vim.api.nvim_get_current_win()
	local height = vim.api.nvim_win_get_height(win)
	vim.api.nvim_win_set_height(win, height - 5)
end, { noremap = true, silent = true, desc = "Decrease pane height" })

-- map for the values sent from wezterm

local super_vim_keys_map_alt = {
	h = 0x2591,
	j = 0x2592,
	k = 0x2593,
	l = 0x2588,
}

-- map h
vim.keymap.set("n", vim.fn.nr2char(super_vim_keys_map_alt["h"]), function()
	local win = vim.api.nvim_get_current_win()
	local width = vim.api.nvim_win_get_width(win)
	vim.api.nvim_win_set_width(win, width - 5)
end, { noremap = true, silent = true })

-- map l
vim.keymap.set("n", vim.fn.nr2char(super_vim_keys_map_alt["l"]), function()
	local win = vim.api.nvim_get_current_win()
	local width = vim.api.nvim_win_get_width(win)
	vim.api.nvim_win_set_width(win, width + 5)
end, { noremap = true, silent = true })

-- map j
vim.keymap.set("n", vim.fn.nr2char(super_vim_keys_map_alt["j"]), function()
	local win = vim.api.nvim_get_current_win()
	local height = vim.api.nvim_win_get_height(win)
	vim.api.nvim_win_set_height(win, height + 5)
end, { noremap = true, silent = true })

-- map k
vim.keymap.set("n", vim.fn.nr2char(super_vim_keys_map_alt["k"]), function()
	local win = vim.api.nvim_get_current_win()
	local height = vim.api.nvim_win_get_height(win)
	vim.api.nvim_win_set_height(win, height - 5)
end, { noremap = true, silent = true })
