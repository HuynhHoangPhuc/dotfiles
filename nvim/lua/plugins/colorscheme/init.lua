return {
	{
		"catppuccin/nvim",
		lazy = false,
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme catppuccin]])

			require("catppuccin").setup({
				integrations = {
					aerial = true,
					cmp = true,
					gitsigns = true,
					harpoon = true,
					illuminate = true,
					leap = true,
					lsp_saga = true,
					lsp_trouble = true,
					markdown = true,
					mason = true,
					mini = true,
					neogit = true,
					neotest = true,
					nvimtree = true,
					overseer = true,
					telescope = true,
					treesitter = true,
					treesitter_context = true,
					which_key = true,

					-- Special integrations, see https://github.com/catppuccin/nvim#special-integrations
					dap = {
						enabled = true,
						enable_ui = true,
					},
					indent_blankline = {
						enabled = true,
						colored_indent_levels = false,
					},
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "underline" },
							hints = { "underline" },
							warnings = { "underline" },
							information = { "underline" },
						},
					},
					navic = {
						enabled = true,
						custom_bg = "NONE",
					},
				},
			})
		end,
	},
}
