return {
	{
		"LunarVim/bigfile.nvim",
	},
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false,
		config = function()
			require("fzf-lua").setup({})
		end,
		keys = {
			-- keep gitignore respect but manually include .env
			{
				"<leader>ff",
				function()
					local cmd = [[rg --files --color=never; rg --files --hidden --no-ignore -g '.env' --color=never]]
					require("fzf-lua").files({ cmd = [[sh -c "]] .. cmd .. [[ | sort -u"]] })
				end,
				desc = "FzfLua Find Files",
			},
			{ "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "FzfLua Live Grep" },
			{ "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "FzfLua Find Buffers" },
			{ "<leader>fh", "<cmd>FzfLua help_tags<CR>", desc = "FzfLua Help Tags" },
			{ "<leader>fc", "<cmd>FzfLua git_status<CR>", desc = "FzfLua Git Status" },
			{ "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", desc = "FzfLua Git Status" },
			{
				"<leader>fm",
				function()
					require("fzf-lua").live_grep({
						prompt = "Merge Conflicts> ",
						search = "^<<<<<<<|^=======|^>>>>>>>",
						no_esc = true,
					})
				end,
				desc = "Find Merge Conflicts",
			},
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		lazy = true,
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({
				-- Your Telescope configuration here
			})
		end,
		keys = {
			{ "<leader>tf", "<cmd>Telescope find_files<CR>", desc = "Telescope Find Files" },
			{ "<leader>tg", "<cmd>Telescope live_grep<CR>", desc = "Telescope Live Grep" },
			{ "<leader>tb", "<cmd>Telescope buffers<CR>", desc = "Telescope Find Buffers" },
			{ "<leader>th", "<cmd>Telescope help_tags<CR>", desc = "Telescope Help Tags" },
			{ "<leader>tc", "<cmd>Telescope git_status<CR>", desc = "Telescope Git Status" },
			{ "<leader>ts", "<cmd>Telescope treesitter<CR>", desc = "Telescope Treesitter Symbols" },
			{ "<leader>td", "<cmd>Telescope diagnostics<CR>", desc = "Telescope Diagnostics" },
		},
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			-- This is your opts table
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({
							-- even more opts
						}),
					},
				},
			})
			-- To get ui-select loaded and working with telescope, you need to call
			-- load_extension, somewhere after setup function:
			require("telescope").load_extension("ui-select")
		end,
	},
	{
		"metakirby5/codi.vim",
		cmd = "Codi",
	},
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

	{
		"windwp/nvim-spectre",
		keys = {
			{ "<C-f>", "<cmd>lua require('spectre').open()<CR>", desc = "Spectre Search" },
		},
		event = "BufRead",
		config = function()
			require("spectre").setup()
		end,
	},

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
