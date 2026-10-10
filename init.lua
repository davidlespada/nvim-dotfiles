require("config.lazy")
require("config.options")
require("config.keymaps")

vim.lsp.enable({ "clangd", "ols", "pyright" })

vim.o.autocomplete = true

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

vim.opt.complete:append("o")
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }
-- number auto suggestions
vim.o.pumheight = 7
vim.o.pumborder = "rounded"

-- format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})
