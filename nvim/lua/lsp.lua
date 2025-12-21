--  refere to https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md to configure LSP servers
local vim = vim
vim.lsp.enable({
	"lua_ls",
	"ruff",
	"pyrefly",
	"pyright",
	-- "ty",
	"yamlls",
	"intelephense",
	"laravel_ls",
	"ts_ls",
  "ruby_lsp"
})

-- vim.diagnostic.config({
--     virtual_lines = {
--         only_current_line = true,
--         -- force using ONLY the main message field
--         format = function(d)
--             return d.message
--         end,
--     },
--     virtual_text = false,   -- 🔴 explicitly disable this
--     underline = true,
--     update_in_insert = false,
--     severity_sort = true,
--     float = {
--         border = "rounded",
--         source = true,
--     },
--     signs = {
--         text = {
--             [vim.diagnostic.severity.ERROR] = "󰅚 ",
--             [vim.diagnostic.severity.WARN]  = "󰀪 ",
--             [vim.diagnostic.severity.INFO]  = "󰋽 ",
--             [vim.diagnostic.severity.HINT]  = "󰌶 ",
--         },
--         numhl = {
--             [vim.diagnostic.severity.ERROR] = "ErrorMsg",
--             [vim.diagnostic.severity.WARN]  = "WarningMsg",
--         },
--     },
-- })

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

		if not client then
			return
		end

		if client.name == "pyrefly" then
			local caps = client.server_capabilities

			caps.hoverProvider = false
			caps.definitionProvider = false
			caps.declarationProvider = false
			caps.referencesProvider = false
			caps.renameProvider = false
			caps.codeActionProvider = false
			caps.documentFormattingProvider = false
			caps.documentRangeFormattingProvider = false
			caps.signatureHelpProvider = nil
			caps.completionProvider = nil
			caps.documentSymbolProvider = false
			caps.workspaceSymbolProvider = false
			caps.documentHighlightProvider = false
			caps.semanticTokensProvider = nil
			caps.inlayHintProvider = nil
			caps.documentOnTypeFormattingProvider = nil
			caps.foldingRangeProvider = false
			caps.typeDefinitionProvider = false
			caps.colorProvider = false
			caps.selectionRangeProvider = false
			-- keep the implementation
			caps.implementationProvider = true
		end

		-- Enable completion triggered by <c-x><c-o>
		buf_set_keymap(bufnr, "i", "<C-x><C-o>", "<cmd>lua vim.lsp.omnifunc()<CR>")

		-- Mappings
		buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
		buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
		buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
		buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
		buf_set_keymap(bufnr, "n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>")
		buf_set_keymap(bufnr, "n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>")
		buf_set_keymap(bufnr, "n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>")
		buf_set_keymap(bufnr, "n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
		buf_set_keymap(bufnr, "n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
		buf_set_keymap(bufnr, "n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
		buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
		buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
		buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>")
		buf_set_keymap(bufnr, "n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>")

		-- set formatter
		-- buf_set_keymap(bufnr, "n", "<leader>cf", "<cmd>lua vim.lsp.buf.format()<CR>")
		--
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
