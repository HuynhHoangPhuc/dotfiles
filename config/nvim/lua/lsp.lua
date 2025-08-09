local M = {}

M.capabilities = require("blink.cmp").get_lsp_capabilities({
	workspace = {
		didChangeWatchedFiles = {
			dynamicRegistration = true,
			relativePatternSupport = true,
		},
	},
}, true)

M.on_attach = function(_, bufnr)
	local map = function(keys, func, desc, mode)
		mode = mode or "n"
		vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
	end

	map("gra", "<cmd>FzfLua lsp_code_actions<cr>", "vim.lsp.buf.code_action()", { "n", "x" })
	map("grr", "<cmd>FzfLua lsp_references<cr>", "vim.lsp.buf.references()")
	map("gri", "<cmd>FzfLua lsp_implementations<cr>", "vim.lsp.buf.implementation()")
	map("gO", "<cmd>FzfLua lsp_document_symbols<cr>", "vim.lsp.buf.document_symbol()")
end

return M
