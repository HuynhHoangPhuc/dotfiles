require("packages.lazy").add({
	src = "https://github.com/stevearc/conform.nvim",
	-- BufReadPre rather than BufWritePre: conform registers its own format-on-save
	-- autocmd during setup, which would be too late for the write that loaded it.
	event = "BufReadPre",
	config = function()
		require("conform").setup(require("languageconfigs").format)

		-- Use conform for gq.
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

		-- Start auto-formatting by default (and disable with my ToggleFormat command).
		vim.g.autoformat = true
	end,
})
