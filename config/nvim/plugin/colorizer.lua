require("packages.lazy").add({
	src = "https://github.com/catgoose/nvim-colorizer.lua",
	ft = {
		"html",
		"css",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"astro",
	},
	config = function()
		require("colorizer").setup({
			filetypes = {
				"html",
				"css",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"astro",
			},
			user_default_options = {
				css = true,
				css_fn = true,
				tailwind = "both",
				tailwind_opts = {
					update_names = true,
				},
				sass = {
					enable = true,
					parsers = { css = true },
				},
				mode = "virtualtext",
				virtualtext = "󱓻",
				virtualtext_inline = "before",
			},
		})
	end,
})
