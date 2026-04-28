return {
	{
		"sindrets/diffview.nvim",
		dependencies = {
			{ "nvim-tree/nvim-web-devicons", lazy = true },
		},

		keys = {
			{
				"dv",
				function()
					if next(require("diffview.lib").views) == nil then
						vim.cmd("DiffviewOpen")
					else
						vim.cmd("DiffviewClose")
					end
				end,
				desc = "Toggle Diffview window",
			},
			{
				"<leader>dv",
				function()
					if next(require("diffview.lib").views) == nil then
						vim.cmd("DiffviewOpen origin/main")
					else
						vim.cmd("DiffviewClose")
					end
				end,
				desc = "Toggle Diffview window",
			},
		},
	},
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
	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		opts = {
			-- or "fzf-lua" or "snacks" or "default"
			picker = "telescope",
			-- bare Octo command opens picker of commands
			enable_builtin = true,
		},
		keys = {
			{
				"<leader>oi",
				"<CMD>tabnew | Octo issue list<CR>",
				desc = "List GitHub Issues",
			},
			{
				"<leader>op",
				"<CMD>tabnew | Octo pr list<CR>",
				desc = "List GitHub PullRequests",
			},
			{
				"<leader>od",
				"<CMD>tabnew | Octo discussion list<CR>",
				desc = "List GitHub Discussions",
			},
			{
				"<leader>on",
				"<CMD>tabnew | Octo notification list<CR>",
				desc = "List GitHub Notifications",
			},
			{
				"<leader>os",
				function()
					vim.cmd("tabnew")
					require("octo.utils").create_base_search_command({ include_current_repo = true })
				end,
				desc = "Search GitHub",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"ibhagwan/fzf-lua",
			-- OR "folke/snacks.nvim",
			"nvim-tree/nvim-web-devicons",
		},
	},
}
