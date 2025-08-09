local M = {}

M.lsp = {
	servers = {
		omnisharp = {
			handlers = {
				["textDocument/definition"] = require("omnisharp_extended").definition_handler,
				["textDocument/typeDefinition"] = require("omnisharp_extended").type_definition_handler,
				["textDocument/references"] = require("omnisharp_extended").references_handler,
				["textDocument/implementation"] = require("omnisharp_extended").implementation_handler,
			},
		},
	},
}

M.format = {
	formatters_by_ft = {
		cs = { "csharpier" },
	},
}

return M
