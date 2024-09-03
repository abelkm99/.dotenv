---@type table
local vim = vim

vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		if vim.bo.filetype == "python" then
			vim.lsp.buf.format()
			vim.lsp.buf.code_action({
				context = { only = { "source.fixAll" }, diagnostics = {} },
				apply = true,
			})
		end
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "zsh",
	callback = function()
		-- let treesitter use bash highlight for zsh files as well
		require("nvim-treesitter.highlight").attach(0, "bash")
	end,
})
