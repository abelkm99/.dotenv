-- -- Make sure to setup `mapleader` and `maplocalleader` before
-- -- loading lazy.nvim so that mappings are correct.
-- -- This is also a good place to setup other settings (vim.opt)
-- vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load basic Neovim options
require("config.options")

-- Load the other options
require("config.other_options")

-- Load key mappings
require("config.keymaps")

-- -- Load autocommands
require("config.autocmds")

require("config.lazy").setup()

require("lazy").setup("plugins")

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.cmd([[colorscheme gruvbox-material]])
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
		vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
	end,
})
