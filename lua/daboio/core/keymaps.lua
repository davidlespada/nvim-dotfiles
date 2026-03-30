-- Setting leader key BEFORE any plugin loads
vim.g.mapleader = " " -- Space as leader key
vim.g.maplocalleader = " "

local keymap = vim.keymap.set -- shorthand

-- Move between windows with Ctrl+hjkl
keymap("n", "<C-h>", "<C-w>h", {desc = "Go to left window"})
keymap("n", "<C-l>", "<C-w>l", {desc = "Go to right window"})
keymap("n", "<C-j>", "<C-w>j", {desc = "Go to lower windws"})
keymap("n", "<C-k>", "C-w>k", {desc = "Go to upper window"})

-- Better up/down on wrapped lines
keymap("n", "j", "gj")
keymap("n", "k", "gk")

-- Clear search highlight with Escape
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Stay in indent mode when indenting in visual
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Diagnostics
keymap("n", "<leader>de", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
keymap("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostics to quickfix list" })
keymap("n", "[d", vim.diagnostic.goto_prev,          { desc = "Previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next,          { desc = "Next diagnostic" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local map = vim.keymap.set
    local buf = event.buf

    -- Navigation
    map("n", "gd", vim.lsp.buf.definition,      { buffer = buf, desc = "Go to definition" })
    map("n", "gD", vim.lsp.buf.declaration,     { buffer = buf, desc = "Go to declaration" })
    map("n", "gi", vim.lsp.buf.implementation,  { buffer = buf, desc = "Go to implementation" })
    map("n", "gr", vim.lsp.buf.references,      { buffer = buf, desc = "Find references" })
    map("n", "gt", vim.lsp.buf.type_definition, { buffer = buf, desc = "Go to type definition" })

    -- Docs
    map("n", "K", vim.lsp.buf.hover,            { buffer = buf, desc = "Hover docs" })

    -- Refactor
    map("n", "<leader>rn", vim.lsp.buf.rename,       { buffer = buf, desc = "Rename symbol" })
    map("n", "<leader>ca", vim.lsp.buf.code_action,  { buffer = buf, desc = "Code action" })

    -- Formatting
    map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, { buffer = buf, desc = "Format file" })
  end,
})
