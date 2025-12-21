--- go config
return {

	cmd = { "gopls" },

	filetypes = { "go", "gomod" },

	-- root_dir = require("lspconfig").util.root_pattern(".git", "go.mod", "."),

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
}
