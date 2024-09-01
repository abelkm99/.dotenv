return {
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		keys = {
			-- 👇 in this section, choose your own keymappings!
			{
				"<leader>-",
				"<cmd>Yazi<cr>",
				desc = "Open yazi at the current file",
			},
			{
				-- Open in the current working directory
				"<leader>cw",
				"<cmd>Yazi cwd<cr>",
				desc = "Open the file manager in nvim's working directory",
			},
			{
				-- NOTE: this requires a version of yazi that includes
				-- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
				"<c-up>",
				"<cmd>Yazi toggle<cr>",
				desc = "Resume the last yazi session",
			},
		},
		---@type YaziConfig
		opts = {
			-- if you want to open yazi instead of netrw, see below for more info
			open_for_directories = false,
			keymaps = {
				show_help = "<f1>",
			},
		},
	},

	{
		"stevearc/oil.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("oil").setup({})
		end,
	},

	{
		"numToStr/Navigator.nvim",
		config = function()
			vim.keymap.set({ "n", "t" }, "<Char-0xB0>", "<CMD>NavigatorLeft<CR>")
			vim.keymap.set({ "n", "t" }, "<Char-0xB1>", "<CMD>NavigatorDown<CR>")
			vim.keymap.set({ "n", "t" }, "<Char-0xB2>", "<CMD>NavigatorUp<CR>")
			vim.keymap.set({ "n", "t" }, "<Char-0xB3>", "<CMD>NavigatorRight<CR>")
			require("Navigator").setup({})
		end,
	},
}
