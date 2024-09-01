return {
	{
		"lewis6991/gitsigns.nvim",
		-- keys = {
		-- 	{ "<leader>gl", "<cmd>Gitsigns blame_line<cr>", desc = "Git blame line" },
		-- 	{ "<leader>gd", "<cmd>Gitsigns diffthis<cr>",   desc = "Git Diff" },
		-- },

		config = function()
			vim.keymap.set("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { silent = true })
			vim.keymap.set("n", "<leader>gl", "<cmd>Gitsigns blame_line<cr>", { silent = true })
			require("gitsigns").setup({})
		end,
	},
}
