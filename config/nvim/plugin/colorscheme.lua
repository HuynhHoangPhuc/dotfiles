require("catppuccin").setup({
	integrations = {
		fzf = true,
		mini = { enable = true },
		copilot_vim = true,
	},
	styles = {
		conditionals = { "italic" },
		keywords = { "italic" },
		loops = { "italic" },
	},
})

vim.cmd.colorscheme("catppuccin")

-- vim.cmd.colorscheme("kanso-zen")
