return {

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "folke/neodev.nvim", opts = {} },
			{ "hrsh7th/cmp-nvim-lsp", opts = {} },
			-- { "ray-x/lsp_signature.nvim", opts = {} },
			{ "hrsh7th/nvim-cmp", opts = {} },
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
}
