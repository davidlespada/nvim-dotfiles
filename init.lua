-- Minimal Neovim config (from scratch)
-- This is step 0: no plugins, just vanilla options.
-- We will add modules (options, keymaps, plugins) one by one.

-- Leader key: must be set BEFORE any plugins/keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Setup lazy.nvim (auto-clone on fresh machines)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options (each one explained)
vim.opt.number = true         -- show line numbers
vim.opt.relativenumber = false -- absolute numbers (toggle later if you want)
vim.opt.tabstop = 2           -- a Tab = 2 spaces wide
vim.opt.shiftwidth = 2        -- auto-indent width
vim.opt.expandtab = true      -- Tab key inserts spaces
vim.opt.termguicolors = true  -- 24-bit color
vim.opt.signcolumn = "yes"    -- always show gutter (avoids text shift)
vim.opt.cursorline = true     -- highlight current line
vim.opt.scrolloff = 8         -- keep 8 lines visible around cursor
vim.opt.ignorecase = true     -- /search case-insensitive...
vim.opt.smartcase = true      -- ...unless capital letter used
vim.opt.splitright = true     -- :vsplit opens right
vim.opt.splitbelow = true     -- :split opens below
vim.opt.updatetime = 250      -- faster CursorHold / diagnostics
vim.opt.timeoutlen = 300      -- faster which-key popup

-- One sanity keymap: clear search highlight with <Esc>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

print("clean init.lua loaded")

require("lazy").setup("daboio.plugins")
