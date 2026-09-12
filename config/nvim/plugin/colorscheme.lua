require("packages.lazy").add({
	src = "https://github.com/catppuccin/nvim",
	name = "catppuccin",
	config = function()
		require("catppuccin").setup({
			integrations = {
				-- MiniFiles*, and the rest of mini.nvim
				mini = { enabled = true },
				telescope = { enabled = true },
			},
			styles = {
				conditionals = { "italic" },
				keywords = { "italic" },
				loops = { "italic" },
			},
			color_overrides = {
				mocha = {
					base = "#000000",
					mantle = "#000000",
					crust = "#000000",
				},
			},
		})

		vim.cmd.colorscheme("catppuccin")
	end,
})
