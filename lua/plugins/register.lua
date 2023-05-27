return {
  {
    "decaycs/decay.nvim",
    lazy = false,
    priority = 1000,
    branch = "refactor",
    config = function ()
      require "plugins.configs.decay"
    end
  },
  {
    "windwp/nvim-autopairs",
    config = function ()
      require "plugins.configs.autopairs"
    end
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    lazy = true,
    keys = {
      { '<space>fn', '<cmd>NvimTreeToggle<cr>', desc = "Toggle files tree" },
      { '<C-n>', '<cmd>NvimTreeToggle<cr>', desc = "Toggle file tree (alt)" },
    },
    opts = {
      use_default_keymaps = false,
    },
    config = function ()
      require "plugins.configs.ntree"
    end
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.1",
    dependencies = {"nvim-lua/plenary.nvim"},
    cmd = "Telescope",
    keys = {
      { '<space>ff', '<cmd>Telescope find_files<cr>', desc = "Find files" },
      { '<space>fg', '<cmd>Telescope live_grep<cr>', desc = "Live GREP" },
      { '<space>fb', '<cmd>Telescope buffers<cr>', desc = "Buffers" },
      { '<space>fh', '<cmd>Telescope help_tags<cr>', desc = "Help tags" },
    },
    opts = {
      use_default_keymaps = false,
    }
  },
  {
    "nvim-treesitter/nvim-treesitter",
    config = function ()
      require "plugins.configs.treesitter"
    end
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function ()
      require "colorizer".setup()
    end
  },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function ()
      require "mason".setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig"
    },
    config = function ()
      require "plugins.configs.nvim-lspconfig"
    end
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function ()
      require "plugins.configs.cmp"
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    config = function ()
      require "plugins.configs.lualine"
    end
  }
}
