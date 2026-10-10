vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Use terminal/shell theme instead of a custom colorscheme
vim.opt.termguicolors = true
-- Theme is set by catppuccin/nvim in lua/plugins/init.lua (flavour mocha,
-- transparent_background = true). Keep this file free of colorscheme overrides
-- so it doesn't fight the theme on startup.
