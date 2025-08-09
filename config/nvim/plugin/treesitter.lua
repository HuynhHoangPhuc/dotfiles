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
	}
end

require("nvim-treesitter.configs").setup({
	auto_install = false,
	indent = { enable = true },
	highlight = {
		enable = true,

		-- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
		disable = function(_, buf)
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats =
				pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,

		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},
	ensure_installed = ensure_installed,
})
