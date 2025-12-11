return {
	{
		"stevearc/conform.nvim",
		opts = {},
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					-- Conform will run the first available formatter
					typescript = { "prettier" },

					lua = { "stylua" },
					-- Conform will run multiple formatters sequentially
					go = { "goimports", "gofmt" },
					-- You can also customize some of the format options for the filetype
					rust = { "rustfmt", lsp_format = "fallback" },
					json = { "prettier" },
					zig = { "zigfmt" },
					-- You can use a function here to determine the formatters dynamically
					python = function(bufnr)
						if require("conform").get_formatter_info("ruff_format", bufnr).available then
							return { "isort", "black", "ruff_format" }
						else
							return { "isort", "black" }
						end
					end,
					-- Use the "*" filetype to run formatters on all filetypes.
					["*"] = { "codespell" },
					-- Use the "_" filetype to run formatters on filetypes that don't
					-- have other formatters configured.
					["_"] = { "trim_whitespace" },
				},
			})

			vim.api.nvim_create_user_command("ConformFormat", function()
				require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
			end, {})
		end,
	},

}
