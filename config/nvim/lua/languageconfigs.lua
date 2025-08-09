local M = {}

local icons = require("icons")

M.lsp = {
	diagnostics = {
		underline = true,
		update_in_insert = false,
		virtual_text = {
			spacing = 4,
			source = "if_many",
			-- prefix = "",
			-- this will set set the prefix to a function that returns the diagnostics icon based on the severity
			-- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
			prefix = "icons",
		},
		severity_sort = true,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
				[vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
				[vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
				[vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
			},
		},
	},
	-- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
	-- Be aware that you also will need to properly configure your LSP server to
	-- provide the inlay hints.
	inlay_hints = {
		enabled = true,
		exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
	},
	-- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
	-- Be aware that you also will need to properly configure your LSP server to
	-- provide the code lenses.
	codelens = {
		enabled = false,
	},
	-- Enable lsp cursor word highlighting
	document_highlight = {
		enabled = true,
	},
	-- add any global capabilities here
	capabilities = {
		workspace = {
			fileOperations = {
				didRename = true,
				willRename = true,
			},
			didChangeWatchedFiles = {
				dynamicRegistration = true,
				relativePatternSupport = true,
			},
		},
	},
	servers = {},
	setup = {},
}

M.format = {
	notify_on_error = false,
	default_format_opts = {
		timeout_ms = 500,
		async = false, -- not recommended to change
		quiet = false, -- not recommended to change
		lsp_format = "fallback", -- not recommended to change
	},
	formatters_by_ft = {
		["_"] = { "trim_whitespace", "trim_newlines" },
	},
	format_on_save = function()
		-- Don't format when minifiles is open, since that triggers the "confirm without
		-- synchronization" message.
		if vim.g.minifiles_active then
			return nil
		end

		-- Stop if we disabled auto-formatting.
		if not vim.g.autoformat then
			return nil
		end

		return {}
	end,
}

M.lint = {
	-- Event to trigger linters
	events = { "BufWritePost", "BufReadPost", "InsertLeave" },
	linters_by_ft = {},
}

M.dap = {}

if
	type(M.lsp.diagnostics.virtual_text) == "table"
	and M.lsp.diagnostics.virtual_text.prefix == "icons"
then
	M.lsp.diagnostics.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0
			and ""
		or function(diagnostic)
			local diagnostic_icons = icons.diagnostics
			for d, icon in pairs(diagnostic_icons) do
				if
					diagnostic.severity == vim.diagnostic.severity[d:upper()]
				then
					return icon
				end
			end
		end
end

local language_configs = vim.iter(
	vim.api.nvim_get_runtime_file("lua/languages/*.lua", true)
)
	:map(function(file)
		return vim.fn.fnamemodify(file, ":t:r")
	end)
	:totable()
for _, language in pairs(language_configs) do
	local config = require("languages." .. language)
	if config.enabled == nil or config.enabled == true then
		M.lsp.servers = vim.tbl_deep_extend(
			"force",
			M.lsp.servers,
			(config.lsp and config.lsp.servers) or {}
		)

		M.lsp.setup = vim.tbl_deep_extend(
			"force",
			M.lsp.setup,
			(config.lsp and config.lsp.setup) or {}
		)

		M.format = vim.tbl_deep_extend("force", M.format, config.format or {})

		M.lint = vim.tbl_deep_extend("force", M.lint, config.lint or {})

		if config.dap then
			M.dap[#M.dap + 1] = config.dap
		end
	end
end

return M
