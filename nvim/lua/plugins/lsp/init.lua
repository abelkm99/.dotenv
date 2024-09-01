return {
  -- Import plugins
  require("plugins.lsp.lsps"),
  require("plugins.lsp.completions"),
  -- Setup LSP configuration
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("plugins.lsp.lsp_config").setup()
    end,
  },
}
