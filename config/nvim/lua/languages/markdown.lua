local M = {}

vim.filetype.add({
	extension = { mdx = "markdown.mdx" },
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.colorcolumn = ""
	end,
})

M.lsp = {
	servers = {
		marksman = {},
	},
}

M.format = {
	formatters_by_ft = {
		markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
		["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
	},
	formatters = {
		["markdown-toc"] = {
			condition = function(_, ctx)
				for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
					if line:find("<!%-%- toc %-%->") then
						return true
					end
				end
			end,
		},
		["markdownlint-cli2"] = {
			condition = function(_, ctx)
				local diag = vim.tbl_filter(function(d)
					return d.source == "markdownlint"
				end, vim.diagnostic.get(ctx.buf))
				return #diag > 0
			end,
		},
	},
}

M.lint = {
	linters_by_ft = {
		markdown = { "markdownlint-cli2" },
	},
	linters = {
		["markdownlint-cli2"] = {
			args = { "--config", '{"MD013": false}', "--" },
		},
	},
}

return M
