return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				-- Add your Treesitter configuration here
				ensure_installed = { "lua", "vim", "vimdoc", "query", "python", "bash" },
				auto_install = true,
				sync_install = false,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
			})
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		lazt = true,
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
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({
				options = {
					-- numbers = "ordinal",
					-- diagnostics = "nvim_lsp",
					-- show_buffer_close_icons = true,
					-- show_close_icon = true,
					-- show_tab_indicators = false,
					-- separator_style = "thin",
					always_show_bufferline = true,
				},
			})
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local handle = io.popen("whoami")
			local whoami = handle:read("*a")
			handle:close()
			whoami = whoami:gsub("^%s*(.-)%s*$", "%1")

			local os = function()
				return " "
			end

			local dev = function()
				return "🧔💻" .. whoami
			end

			local clients_lsp = function()
				local bufnr = vim.api.nvim_get_current_buf()

				local clients = vim.lsp.buf_get_clients(bufnr)
				if next(clients) == nil then
					return ""
				end

				local c = {}
				for _, client in pairs(clients) do
					table.insert(c, client.name)
				end
				return "\u{f085} " .. table.concat(c, "|")
			end
			local lint_progress = function()
				local linters = require("lint").get_running()
				if #linters == 0 then
					return "󰦕"
				end
				return "󱉶 " .. table.concat(linters, ", ")
			end
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "auto",
				},
				sections = {
					lualine_x = { lint_progress, clients_lsp, os, "filetype" },

					lualine_z = {
						dev,
					},
				},
			})
		end,
	},
	{
		"folke/todo-comments.nvim",
		event = "BufRead",
		config = function()
			require("todo-comments").setup({})
		end,
	},
	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{
		{
			"numToStr/Comment.nvim",
			opts = {
				-- Configuration options, if any
			},
			keys = {
				{ "<leader>/", mode = { "n", "v" } },
			},
			config = function()
				require("Comment").setup({
					ignore = "^$",
				})

				vim.keymap.set("n", "<leader>/", function()
					require("Comment.api").toggle.linewise.current()
				end, { desc = "Toggle comment" })

				vim.keymap.set(
					"v",
					"<leader>/",
					"<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
					{ desc = "Toggle comment for selection" }
				)
			end,
		},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		-- Optional dependency
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			require("nvim-autopairs").setup({})
			-- If you want to automatically add `(` after selecting a function or method
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{ -- Add indentation guides even on blank lines
		"lukas-reineke/indent-blankline.nvim",
		-- Enable `lukas-reineke/indent-blankline.nvim`
		-- See `:help ibl`
		main = "ibl",
		opts = {},
	},
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("refactoring").setup()
		end,
	},
	{
		"ThePrimeagen/harpoon",
		config = function()
			vim.keymap.set(
				"n",
				"<leader>a",
				"<cmd>lua require('harpoon.mark').add_file()<CR>",
				{ desc = "Add file to harpoon" }
			)
			vim.keymap.set(
				"n",
				"<leader>h",
				"<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>",
				{ desc = "Toggle harpoon" }
			)
			vim.keymap.set(
				"n",
				"<leader>1",
				":lua require('harpoon.ui').nav_file(1)<cr>",
				{ desc = "Open harpoon file 1" }
			)
			vim.keymap.set(
				"n",
				"<leader>2",
				":lua require('harpoon.ui').nav_file(2)<cr>",
				{ desc = "Open harpoon file 2" }
			)
			vim.keymap.set(
				"n",
				"<leader>3",
				":lua require('harpoon.ui').nav_file(3)<cr>",
				{ desc = "Open harpoon file 3" }
			)
			vim.keymap.set(
				"n",
				"<leader>4",
				":lua require('harpoon.ui').nav_file(4)<cr>",
				{ desc = "Open harpoon file 4" }
			)
			vim.keymap.set(
				"n",
				"<leader>5",
				":lua require('harpoon.ui').nav_file(5)<cr>",
				{ desc = "Open harpoon file 5" }
			)
			vim.keymap.set(
				"n",
				"<leader>6",
				":lua require('harpoon.ui').nav_file(6)<cr>",
				{ desc = "Open harpoon file 6" }
			)
			require("harpoon").setup({})
		end,
	},
	{
		"hedyhli/outline.nvim",
		keys = {
			{ "<leader>o", "<cmd>Outline<CR>", desc = "Toggle Outline" },
		},
		config = function()
			require("outline").setup({})
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
	},
	{
		"mistricky/codesnap.nvim",
		build = "make",
		config = function()
			require("codesnap").setup({
				watermark = "bella",
				bg_teme = "dusk",
			})
		end,
	},
	{
		"MeanderingProgrammer/markdown.nvim",
		main = "render-markdown",
		opts = {},
		name = "render-markdown", -- Only needed if you have another plugin named markdown.nvim
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
	},
	{
		"epwalsh/pomo.nvim",
		version = "*", -- Recommended, use latest release instead of latest commit
		lazy = true,
		cmd = { "TimerStart", "TimerRepeat", "TimerSession" },
		dependencies = {
			-- Optional, but highly recommended if you want to use the "Default" timer
			"rcarriga/nvim-notify",
		},
	},
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			{ "MunifTanjim/nui.nvim" },
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			{
				"rcarriga/nvim-notify",
				config = function()
					require("notify").setup({
						level = "error",
					})
				end,
			},
		},
	},
}
