local M = {}

M.lsp = {
	servers = {
		lua_ls = {
			settings = {
				Lua = {
					workspace = {
						library = {
							vim.fn.expand("$VIMRUNTIME/lua"),
							vim.fn.stdpath("data")
								.. "/lazy/lazy.nvim/lua/lazy",
							"${3rd}/luv/library",
						},
					},
				},
			},
		},
	},
}

M.format = {
	formatters_by_ft = {
		lua = { "stylua" },
	},
}

return M
