local opt = vim.opt

-- Line numbers

opt.number = true -- Show numbers
opt.relativenumber = false -- Show relative numbers

-- Tabs & indentation
opt.tabstop = 2 -- a tab character = 2 spaces
opt.shiftwidth = 2 -- >> and << indent by 2 spaces
opt.expandtab = true -- pressing Tab insert spaces
opt.autoindent = true -- copy indent from current line

-- UI
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300
