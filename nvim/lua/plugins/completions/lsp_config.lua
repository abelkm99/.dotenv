local M
---@type table
local vim = vim

function M.setup()
	-- local lspconfig = require("lspconfig")
	local capabilities = require("cmp_nvim_lsp").default_capabilities()



	local pyright_opts = {
		single_file_support = true,
		settings = {
			pyright = {
				disableLanguageServices = false,
				disableOrganizeImports = false,
			},
			python = {
				analysis = {
					autoImportCompletions = true,
					autoSearchPaths = true,
					diagnosticMode = "workspace", -- Can be 'openFilesOnly' or 'workspace'
					typeCheckingMode = "standard", -- Can be 'off', 'basic', 'standard',or 'strict'
					useLibraryCodeForTypes = true,
				},
			},
		},
	}

	local ruff_opts = {
		settings = {
			ruff = {
				lint = {
					run = "onType",
				},
				organizeImports = true,
				fixAll = true,
			},
		},
	}

	-- LSP server setups
	-- lspconfig.pyright.setup({
	-- 	capabilities = capabilities,
	-- 	single_file_support = pyright_opts.single_file_support,
	-- 	settings = pyright_opts.settings,
	-- })

	-- lspconfig.eslint.setup({
	-- 	capabilities = capabilities,
	-- })

	-- lspconfig.ts_ls.setup({
	-- 	capabilities = capabilities,
	-- })

	-- lspconfig.ruff.setup({
	-- 	capabilities = capabilities,
	-- 	settings = ruff_opts.settings,
	-- })

	-- add rust analyzer

	-- lspconfig.rust_analyzer.setup({
	-- 	capabilities = capabilities,
	-- })
	-- lspconfig.dockerls.setup({})
	-- lspconfig.clangd.setup({})
	-- lspconfig.zls.setup({
	-- 	settings = {
	-- 		settings = {
	-- 			zls = {
	-- 				auto_save = false,
	-- 				enable_build_on_save = true,
	-- 				build_on_save_step = "check",
	-- 			},
	-- 		},
	-- 	},
	-- })
	-- lspconfig.jsonls.setup({
	-- 	capabilities = capabilities,
	-- 	settings = {
	-- 		json = {
	-- 			schemas = {
	-- 				{
	-- 					fileMatch = { "package.json" },
	-- 					url = "https://json.schemastore.org/package.json",
	-- 				},
	-- 				{
	-- 					fileMatch = { "tsconfig*.json" },
	-- 					url = "https://json.schemastore.org/tsconfig.json",
	-- 				},
	-- 				-- Add more schemas as needed
	-- 			},
	-- 			validate = { enable = true },
	-- 		},
	-- 	},
	-- })
	-- -- configure yamlls
	-- lspconfig.yamlls.setup({
	-- })

	-- vim.lsp.config("lua_ls", {

	-- 	capabilities = capabilities,
	-- })
	-- vim.lsp.enable({
	-- 	"lua_ls",
	-- 	-- add any others you configured
	-- })
end

return M
