return {
  {
    "LunarVim/bigfile.nvim"
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
      require("fzf-lua").setup({})
    end,
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<CR>",                desc = "FzfLua Find Files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>",            desc = "FzfLua Live Grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<CR>",              desc = "FzfLua Find Buffers" },
      { "<leader>fh", "<cmd>FzfLua help_tags<CR>",            desc = "FzfLua Help Tags" },
      { "<leader>fc", "<cmd>FzfLua git_status<CR>",           desc = "FzfLua Git Status" },
      { "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", desc = "FzfLua Git Status" },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    lazy = true,
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        -- Your Telescope configuration here
      })
    end,
    keys = {
      { "<leader>tf", "<cmd>Telescope find_files<CR>",  desc = "Telescope Find Files" },
      { "<leader>tg", "<cmd>Telescope live_grep<CR>",   desc = "Telescope Live Grep" },
      { "<leader>tb", "<cmd>Telescope buffers<CR>",     desc = "Telescope Find Buffers" },
      { "<leader>th", "<cmd>Telescope help_tags<CR>",   desc = "Telescope Help Tags" },
      { "<leader>tc", "<cmd>Telescope git_status<CR>",  desc = "Telescope Git Status" },
      { "<leader>ts", "<cmd>Telescope treesitter<CR>",  desc = "Telescope Treesitter Symbols" },
      { "<leader>td", "<cmd>Telescope diagnostics<CR>", desc = "Telescope Diagnostics" },
    },
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      -- This is your opts table
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
              -- even more opts
            }
          }
        }
      }
      -- To get ui-select loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require("telescope").load_extension("ui-select")
    end
  },
  {
    "metakirby5/codi.vim",
    cmd = "Codi",
  },
  {
    "windwp/nvim-spectre",
    keys = {
      { "<C-f>", "<cmd>lua require('spectre').open()<CR>", desc = "Spectre Search" }
    },
    event = "BufRead",
    config = function()
      require("spectre").setup()
    end,
  },




}
