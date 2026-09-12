-- https://github.com/NvChad/ui/blob/v3.0/lua/nvchad/mason/init.lua
local M = {}
local mason_names = require("packages.names")
local pkgs = {}

-- Mason installers that shell out to a toolchain Mason does not itself provide.
-- Requesting one without its runtime fails, and because a failed install never
-- records a version the package is retried on every startup.
local install_runtime = {
	csharpier = "dotnet",
}

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
		local pkg = mason_names[v]
		local runtime = pkg and install_runtime[pkg]

		if
			pkg
			and not vim.list_contains(pkgs, pkg)
			and (not runtime or vim.fn.executable(runtime) == 1)
		then
			table.insert(pkgs, pkg)
		end
	end

	return pkgs
end

-- get_package throws for a name the local registry does not know about, which
-- happens before the registry has been downloaded for the first time.
local function each_pkg(fn)
	local mr = require("mason-registry")

	for _, tool in ipairs(M.get_pkgs()) do
		local ok, p = pcall(mr.get_package, tool)
		if ok then fn(p) end
	end
end

-- Startup path: install what is missing, using the registry already on disk.
-- No refresh and no version check, so this costs nothing once everything is in.
M.install_missing = function()
	each_pkg(function(p)
		if not p:is_installed() then p:install() end
	end)
end

-- :MasonUpdateAll - refresh the registry, then install missing packages and
-- upgrade the ones that are behind.
M.update_all = function()
	require("mason-registry").refresh(function()
		each_pkg(function(p)
			if not p:is_installed() then
				p:install()
			else
				local ok, latest = pcall(p.get_latest_version, p)
				if ok and latest and p:get_installed_version() ~= latest then p:install() end
			end
		end)
	end)
end

M.setup = function()
	vim.api.nvim_create_user_command(
		"MasonUpdateAll",
		M.update_all,
		{ desc = "Install missing and update outdated Mason packages" }
	)

	-- Walking the registry is the expensive half of this, and nothing on screen
	-- depends on the result. mason.setup() itself stays eager, in plugin/mason.lua.
	vim.schedule(M.install_missing)
end

return M
