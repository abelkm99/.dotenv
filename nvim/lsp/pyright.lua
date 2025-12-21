return {
  cmd = { "pyright-langserver", "--stdio" }, -- make sure this is in your PATH

  filetypes = { "python" },

  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    "pyrightconfig.json",
    ".git",
  },

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
        diagnosticMode = "workspace",   -- 'openFilesOnly' or 'workspace'
        typeCheckingMode = "standard",  -- 'off' | 'basic' | 'standard' | 'strict'
        useLibraryCodeForTypes = true,
      },
    },
  },
}
