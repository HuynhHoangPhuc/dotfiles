local ensure_installed = {}

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
		"markdown",
		"markdown_inline",
	}
end

local ok, treesitter = pcall(require, "nvim-treesitter")

if not ok then
	vim.schedule(function()
		vim.notify("nvim-treesitter is unavailable", vim.log.levels.WARN)
	end)
	return
end

if #ensure_installed > 0 then
	local installed = treesitter.get_installed()

	local missing = vim.iter(ensure_installed)
		:filter(function(lang)
			return not vim.tbl_contains(installed, lang)
		end)
		:totable()

	if #missing > 0 then
		vim.schedule(function()
			local install_ok = pcall(treesitter.install, missing)

			if not install_ok then
				vim.notify(
					"nvim-treesitter parser install failed",
					vim.log.levels.WARN
				)
			end
		end)
	end
end

local uv = vim.uv or vim.loop

local function is_large_file(buf)
	local max_filesize = 100 * 1024 -- 100 KB
	local ok_stat, stats = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(buf))

	return ok_stat and stats and stats.size > max_filesize
end

local group =
	vim.api.nvim_create_augroup("dotfiles-treesitter", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function(args)
		if is_large_file(args.buf) then
			return
		end

		pcall(vim.treesitter.start, args.buf)
	end,
})
