return {
  -- Start the language server
  cmd = { "uvx", "ty", "server" },  -- official docs say: use the `server` subcommand :contentReference[oaicite:0]{index=0}

  filetypes = { "python" },

  -- How to detect the project root
  root_markers = {
    "ty.toml",
    "pyproject.toml",
    ".git",
  },

  single_file_support = true,
  settings = {
      ty = {
        diagnosticMode = "openFilesOnly", -- default is already this, but being explicit is fine
      },
  },

  -- Optional: init_options if you want a log file (nice for debugging)
  -- init_options = {
  --   logFile = vim.fn.stdpath("cache") .. "/ty.log",
  -- },
}
