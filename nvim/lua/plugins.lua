return {
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
	},

	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- calling `setup` is optional for customization
			require("fzf-lua").setup({})
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			"3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
		},
		config = function()
			require("neo-tree").setup({
				filesystem = {
					filtered_items = {
						visible = false, -- This line makes hidden files visible by default
						hide_dotfiles = false, -- This line ensures dotfiles are not hidden
						hide_gitignored = true, -- This line ensures gitignored files are not hidden
					},
				},
				enable_git_status = true,
				enable_diagnostics = true,
				-- vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>")
			})
		end,
	},
}
