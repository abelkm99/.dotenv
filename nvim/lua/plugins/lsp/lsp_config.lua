local M = {}
---
---@type table
local vim = vim

function M.setup()
	local lspconfig = require("lspconfig")
	local capabilities = require("cmp_nvim_lsp").default_capabilities()

	-- Function to set keymaps
	local function buf_set_keymap(bufnr, mode, lhs, rhs, opts)
		vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts or { noremap = true, silent = true })
	end

	-- Use LspAttach autocommand to only map the following keys
	-- after the language server attaches to the current buffer
	vim.api.nvim_create_autocmd("LspAttach", {

		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			local bufnr = ev.buf
			local client = vim.lsp.get_client_by_id(ev.data.client_id)

			-- Enable completion triggered by <c-x><c-o>
			buf_set_keymap(bufnr, "i", "<C-x><C-o>", "<cmd>lua vim.lsp.omnifunc()<CR>")

			-- Mappings
			buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
			buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
			buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
			buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
			buf_set_keymap(bufnr, "n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>")
			buf_set_keymap(bufnr, "n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>")
			buf_set_keymap(
				bufnr,
				"n",
				"<space>wl",
				"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>"
			)
			buf_set_keymap(bufnr, "n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
			buf_set_keymap(bufnr, "n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
			buf_set_keymap(bufnr, "n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
			buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
			buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
			buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>")
			buf_set_keymap(bufnr, "n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>")

			-- set formatter
			buf_set_keymap(bufnr, "n", "<leader>cf", "<cmd>lua vim.lsp.buf.format()<CR>")

			-- Add the new mapping for fzf-lua code actions
			buf_set_keymap(
				bufnr,
				"n",
				"<leader>ca",
				"<cmd>lua require('fzf-lua').lsp_code_actions({ winopts = { relative = 'cursor', width = 0.6, height = 0.6, row = 1, preview = { vertical = 'up:70%' } } })<CR>",
				{ desc = "Code actions" }
			)

			-- If you want to add it for visual mode as well
			buf_set_keymap(
				bufnr,
				"v",
				"<leader>ca",
				"<cmd>lua require('fzf-lua').lsp_code_actions({ winopts = { relative = 'cursor', width = 0.6, height = 0.6, row = 1, preview = { vertical = 'up:70%' } } })<CR>",
				{ desc = "Code actions" }
			)
		end,
	})

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
	lspconfig.pyright.setup({
		capabilities = capabilities,
		single_file_support = pyright_opts.single_file_support,
		settings = pyright_opts.settings,
	})
	lspconfig.ruff_lsp.setup({
		capabilities = capabilities,
		settings = ruff_opts.settings,
	})

	lspconfig.lua_ls.setup({
		capabilities = capabilities,
	})

	lspconfig.tsserver.setup({
		capabilities = capabilities,
	})

	--- go config
	lspconfig.gopls.setup({

		cmd = { "gopls" },

		filetypes = { "go", "gomod" },

		root_dir = require("lspconfig").util.root_pattern(".git", "go.mod", "."),

		settings = {

			gopls = {

				experimentalPostfixCompletions = true,

				analyses = {
					unusedparams = true,
					shadow = true,
				},

				staticcheck = true,

				usePlaceholders = true,

				gofumpt = true,

				codelenses = {

					generate = false,

					gc_details = true,

					test = true,

					tidy = true,
				},
			},
		},

		capabilities = capabilities,
	})

	lspconfig.dockerls.setup({})
end

return M
