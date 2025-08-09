local M = {}

M.enabled = vim.fn.executable("nix") == 1

M.lsp = {
	servers = {
		nil_ls = {},
	},
}

M.format = {
	formatters_by_ft = {
		nix = { "nixfmt" },
	},
}

return M
