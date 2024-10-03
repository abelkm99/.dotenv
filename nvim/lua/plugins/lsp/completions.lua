return {
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
	},
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local icons = require("plugins.icons.icons")
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			local source_names = {
				nvim_lsp = "(LSP)",
				emoji = "(Emoji)",
				path = "(Path)",
				calc = "(Calc)",
				cmp_tabnine = "(Tabnine)",
				vsnip = "(Snippet)",
				luasnip = "(Snippet)",
				buffer = "(Buffer)",
				tmux = "(TMUX)",
				copilot = "(Copilot)",
				treesitter = "(TreeSitter)",
			}
			local duplicates = {
				buffer = 1,
				path = 1,
				nvim_lsp = 0,
				luasnip = 1,
			}
			local duplicates_default = 0

			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
				    and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") ==
				    nil
			end

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					duplicates_default = 0,
					format = function(entry, vim_item)
						local max_width = 0
						-- if max_width ~= 0 and #vim_item.abbr > max_width then
						-- 	vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) ..
						-- 	lvim.icons.ui.Ellipsis
						-- end
						vim_item.kind = icons.kind[vim_item.kind]

						if entry.source.name == "copilot" then
							vim_item.kind = icons.git.Octoface
							vim_item.kind_hl_group = "CmpItemKindCopilot"
						end

						if entry.source.name == "cmp_tabnine" then
							vim_item.kind = icons.misc.Robot
							vim_item.kind_hl_group = "CmpItemKindTabnine"
						end

						if entry.source.name == "crates" then
							vim_item.kind = icons.misc.Package
							vim_item.kind_hl_group = "CmpItemKindCrate"
						end

						if entry.source.name == "lab.quick_data" then
							vim_item.kind = icons.misc.CircuitBoard
							vim_item.kind_hl_group = "CmpItemKindConstant"
						end

						if entry.source.name == "emoji" then
							vim_item.kind = icons.misc.Smiley
							vim_item.kind_hl_group = "CmpItemKindEmoji"
						end
						vim_item.menu = source_names[entry.source.name]
						vim_item.dup = duplicates[entry.source.name] or duplicates_default
						return vim_item
					end,
				},
				sources = cmp.config.sources({
					{
						name = "copilot",
						-- keyword_length = 0,
						max_item_count = 3,
						trigger_characters = {
							{
								".",
								":",
								"(",
								"'",
								'"',
								"[",
								",",
								"#",
								"*",
								"@",
								"|",
								"=",
								"-",
								"{",
								"/",
								"\\",
								"+",
								"?",
								" ",
								-- "\t",
								-- "\n",
							},
						},
					},
					{
						name = "nvim_lsp",
						max_item_count = 7,
						entry_filter = function(entry, ctx)
							local kind = require("cmp.types.lsp").CompletionItemKind
							    [entry:get_kind()]

							-- Filter out snippets for Java files
							if kind == "Snippet" and ctx.prev_context.filetype == "java" then
								return false
							end

							-- Filter out entries with unwanted spaces
							local completion_item = entry:get_completion_item()
							if completion_item and completion_item.label then
								-- Check if the label contains spaces that weren't in the original input
								local input = ctx.cursor_before_line:match("%S+$") or ""
								local label_without_spaces = completion_item.label:gsub(
									"%s+", "")

								if not input:find(" ") and completion_item.label:find(" ") then
									return false
								end
							end

							return true
						end,
					},

					{ name = "path" },
					{ name = "luasnip" },
					{ name = "cmp_tabnine" },
					{ name = "nvim_lua" },
					{ name = "buffer" },
					{ name = "calc" },
					{ name = "emoji" },
					{ name = "treesitter" },
					{ name = "crates" },
					{ name = "tmux" },
				}),
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
			})
		end,
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
		},
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
			})
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end,
	},
}
