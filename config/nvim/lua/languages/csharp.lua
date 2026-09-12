local M = {}

M.lsp = {
	servers = {
		omnisharp = {
			-- Wrapped rather than called here: lua/languageconfigs.lua requires
			-- every language module up front, so a bare require would load
			-- omnisharp-extended whatever the filetype is.
			handlers = {
				["textDocument/definition"] = function(...)
					return require("omnisharp_extended").definition_handler(...)
				end,
				["textDocument/typeDefinition"] = function(...)
					return require("omnisharp_extended").type_definition_handler(...)
				end,
				["textDocument/references"] = function(...)
					return require("omnisharp_extended").references_handler(...)
				end,
				["textDocument/implementation"] = function(...)
					return require("omnisharp_extended").implementation_handler(...)
				end,
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
