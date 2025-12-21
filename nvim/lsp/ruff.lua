return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".git" },
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
