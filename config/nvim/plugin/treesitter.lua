local ensure_installed = {}
local indent_enabled = {
	c = true,
	cpp = true,
	css = true,
	html = true,
	javascript = true,
	javascriptreact = true,
	lua = true,
	typescriptreact = true,
	typescript = true,
	tsx = true,
}

if not os.getenv("DOTFILES_WITH_FLAKE") then
	ensure_installed = {
		"lua",
		"c",
		"cpp",
		"html",
		"css",
		"javascript",
		"typescript",
		"tsx",
	}
end

local ok, treesitter = pcall(require, "nvim-treesitter")

if not ok then
	vim.schedule(function()
		vim.notify("nvim-treesitter is unavailable", vim.log.levels.WARN)
	end)
	return
end

treesitter.setup({
	auto_install = false,
})

if #ensure_installed > 0 then
	vim.schedule(function()
		local installed = pcall(treesitter.install, ensure_installed)

		if not installed then
			vim.notify(
				"nvim-treesitter parser install failed",
				vim.log.levels.WARN
			)
		end
	end)
end

local uv = vim.uv or vim.loop

local function is_large_file(buf)
	local max_filesize = 100 * 1024 -- 100 KB
	local ok_stat, stats = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(buf))

	return ok_stat and stats and stats.size > max_filesize
end

local group = vim.api.nvim_create_augroup("dotfiles-treesitter", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function(args)
		if is_large_file(args.buf) then
			return
		end

		local started = pcall(vim.treesitter.start, args.buf)
		local filetype = vim.bo[args.buf].filetype

		if started and indent_enabled[filetype] then
			vim.bo[args.buf].indentexpr =
				"v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})
