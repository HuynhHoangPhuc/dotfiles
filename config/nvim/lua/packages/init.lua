-- https://github.com/NvChad/ui/blob/v3.0/lua/nvchad/mason/init.lua
local M = {}
local mason_names = require("packages.names")
local pkgs = {}

M.get_pkgs = function()
	local tools = {}
	local langconfigs = require("languageconfigs")

	-- LSP servers from languageconfigs (source of truth)
	vim.list_extend(tools, vim.tbl_keys(langconfigs.lsp.servers))

	-- Formatters from languageconfigs
	for _, fmts in pairs(langconfigs.format.formatters_by_ft) do
		vim.list_extend(tools, fmts)
	end

	-- Linters from languageconfigs
	for _, lints in pairs(langconfigs.lint.linters_by_ft) do
		vim.list_extend(tools, lints)
	end

	for _, v in pairs(tools) do
		if mason_names[v] and not vim.list_contains(pkgs, mason_names[v]) then
			table.insert(pkgs, mason_names[v])
		end
	end

	return pkgs
end

M.install_all = function()
	local mr = require("mason-registry")

	mr.refresh(function()
		for _, tool in ipairs(M.get_pkgs()) do
			local p = mr.get_package(tool)

			if not p:is_installed() then
				p:install()
			else
				local ok, latest = pcall(p.get_latest_version, p)
				if ok and latest and p:get_installed_version() ~= latest then
					p:install()
				end
			end
		end
	end)
end

return M
