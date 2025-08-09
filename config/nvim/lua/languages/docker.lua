local M = {}

M.lsp = {
	servers = {
		dockerls = {},
		docker_compose_language_service = {},
	},
}

M.lint = {
	linters_by_ft = {
		dockerfile = { "hadolint" },
	},
}

return M
