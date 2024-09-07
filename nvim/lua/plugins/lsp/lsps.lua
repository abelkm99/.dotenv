return {

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "folke/neodev.nvim",    opts = {} },
			{ "hrsh7th/cmp-nvim-lsp", opts = {} },
			-- { "ray-x/lsp_signature.nvim", opts = {} },
			{ "hrsh7th/nvim-cmp",     opts = {} },
		},
	},
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({

				ensure_installed = { "lua_ls", "rust_analyzer", "tsserver" },
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")

			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.prettier,
					null_ls.builtins.formatting.black,
					null_ls.builtins.formatting.goimports,
					null_ls.builtins.formatting.isort,
					null_ls.builtins.formatting.clang_format,
					-- null_ls.builtins.diagnostics.eslint_d,
					null_ls.builtins.completion.spell,
				},
			})
		end,
	},
}
