---@type table
local vim = vim

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   callback = function(args)
    -- vim.lsp.buf.format()
    -- require("conform").format({ bufnr = args.buf })
    -- if vim.bo.filetype == "pythonnn" or vim.bo.filetype == "go" then
    -- 	vim.lsp.buf.code_action({
    -- 		context = { only = { "source.fixAll" }, diagnostics = {} },
    -- 		apply = true,
    -- 	})
    -- end
--   end,
-- })

-- Treat .env and .env.* as shell so commentstring works (# %s)
vim.filetype.add({
  filename = { [".env"] = "sh" },
  pattern = { ["%.env%..*"] = "sh" },
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function()
    -- let treesitter use bash highlight for zsh files as well
    vim.treesitter.start(0, "bash")
  end,
})

-- nvim-treesitter main branch: highlighting is opt-in per buffer
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
  callback = function()
    -- try_lint without arguments runs the linters defined in `linters_by_ft`
    -- for the current filetype
    require("lint").try_lint()
  end,
})

-- Re-apply transparent background whenever a colorscheme is set
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    -- vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
    -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  end,
})

-- Ghostty ↔ Neovim theme sync lives in config/ghostty_sync.lua (loaded from init.lua).

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- vim.cmd.colorscheme("catppuccin")
    -- vim.cmd.colorscheme("rose-pine")

    local fzf = require("fzf-lua")
    fzf.register_ui_select()
  end,
})
