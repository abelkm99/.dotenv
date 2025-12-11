require("config.options")
require("config.other_options")
require("config.keymaps")

require("lsp")

require("config.lazy").setup()
require("lazy").setup("plugins")

require("config.autocmds")
