return {
	{
		"stevearc/conform.nvim",
		opts = {},
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					-- Conform will run multiple formatters sequentially
					go = { "goimports", "gofmt" },
					-- You can also customize some of the format options for the filetype
					rust = { "rustfmt", lsp_format = "fallback" },
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

					-- Conform will run the first available formatter
					javascript = { "prettierd", "prettier", stop_after_first = true },
				},
			})
		end,
	},

	-- {
	-- 	"nvimtools/none-ls.nvim",
	-- 	config = function()
	-- 		local null_ls = require("null-ls")

	-- 		null_ls.setup({
	-- 			sources = {
	-- 				null_ls.builtins.formatting.stylua,
	-- 				null_ls.builtins.formatting.prettier,
	-- 				null_ls.builtins.formatting.black,
	-- 				null_ls.builtins.formatting.goimports,
	-- 				null_ls.builtins.formatting.isort,
	-- 				null_lsbuiltins.formatting.clang_format,
	-- 				-- null_ls.builtins.diagnostics.eslint_d,
	-- 				null_ls.builtins.completion.spell,
	-- 			},
	-- 		})
	-- 	end,
	-- },
}
