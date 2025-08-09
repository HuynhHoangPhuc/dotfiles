local M = {}

local function extend(t, key, values)
	local keys = vim.split(key, ".", { plain = true })
	for i = 1, #keys do
		local k = keys[i]
		t[k] = t[k] or {}
		if type(t) ~= "table" then
			return
		end
		t = t[k]
	end
	return vim.list_extend(t, values)
end

local function get_pkg_path(pkg, path, opts)
	pcall(require, "mason") -- make sure Mason is loaded. Will fail when generating docs
	local root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
	opts = opts or {}
	-- opts.warn = opts.warn == nil and true or opts.warn
	path = path or ""
	local ret = root .. "/packages/" .. pkg .. "/" .. path

	--   M.warn(
	--     ("Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package."):format(pkg, path)
	--   )
	-- end
	return ret
end

M.lsp = {
	servers = {
		astro = {},
	},
}

M.format = {
	formatters_by_ft = {
		astro = { "prettier" },
	},
}

M.lint = {
	linters_by_ft = {
		astro = { "biomejs" },
	},
}

extend(
	require("languages.typescript").lsp.servers.vtsls,
	"settings.vtsls.tsserver.globalPlugins",
	{
		{
			name = "@astrojs/ts-plugin",
			location = get_pkg_path(
				"astro-language-server",
				"/node_modules/@astrojs/ts-plugin"
			),
			enableForWorkspaceTypeScriptVersions = true,
		},
	}
)

return M
