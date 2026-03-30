return {

  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyonight-night")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "lua", "javascript", "typescript", "python", "bash", "json", "markdown", "c", "cpp"},
        auto_install = true,
        install_dir = vim.fn.stdpath("data") .. "/treesitter",
      })

      require("nvim-treesitter.install").compilers = {"gcc"}
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
        },
      })

      local map = vim.keymap.set
      map("n", "<leader>ff", function() builtin.find_files() end, {desc = "Find files"})
      map("n", "<leader>fg", function() builtin.live_grep() end, {desc = "Live grep"})
      map("n", "<leader>fb", function() builtin.buffers() end, {desc = "Find buffers"})
      map("n", "<leader>fh", function() builtin.help_tags() end, {desc = "Help tags"})
    end
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icon = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  {
    "willamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "pyright",
        },
        automatic_installation = true,
      })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        delay = 300,
      })

      wk.add({
        { "<leader>f", group = "Find (Telescope)" },
        { "<leader>r", group = "Refactor/Rename" },
        { "<leader>c", group = "Code actions" },
        { "<leader>d", group = "Diagnostics" },
      })
    end,
  },

  {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()

    -- LspAttach autocommand stays exactly the same
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(event)
        local map = vim.keymap.set
        map("n", "gd",         vim.lsp.buf.definition,   { buffer = event.buf, desc = "Go to definition" })
        map("n", "K",          vim.lsp.buf.hover,         { buffer = event.buf, desc = "Hover docs" })
        map("n", "gr",         vim.lsp.buf.references,    { buffer = event.buf, desc = "Find references" })
        map("n", "<leader>rn", vim.lsp.buf.rename,        { buffer = event.buf, desc = "Rename symbol" })
        map("n", "<leader>ca", vim.lsp.buf.code_action,   { buffer = event.buf, desc = "Code action" })
      end,
    })

    -- Custom config for lua_ls (the only one needing overrides)
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
        },
      },
    })

    -- Enable all servers (ts_ls and pyright need no overrides)
    vim.lsp.enable({ "lua_ls", "ts_ls", "pyright" })

  end,
},

}
