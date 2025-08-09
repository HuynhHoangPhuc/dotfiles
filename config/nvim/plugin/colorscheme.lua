require("catppuccin").setup({
	integrations = {
		fzf = true,
		mini = { enable = true },
	},
	styles = {
		conditionals = { "italic" },
		keywords = { "italic" },
		loops = { "italic" },
	},
})

vim.cmd.colorscheme("catppuccin")

-- vim.cmd.colorscheme("kanso-zen")
