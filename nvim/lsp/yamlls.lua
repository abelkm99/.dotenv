local yamlls = {
  cmd = {
    "yaml-language-server", "--stdio",
  },
  filetypes = { "yaml", "yml" },
  root_markers = { ".git" },








  settings = {
    yaml = {
      validate = true,
      completion = true,
      hover = true,
      format = { enable = true },
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
    },
  },
}

return yamlls
