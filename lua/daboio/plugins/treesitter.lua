return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "python"},
      auto_install = true,
      highlight = {enable = true},
    })
  end,
}
