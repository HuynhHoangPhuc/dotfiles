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
			parsers = { "css" },
		},
		mode = "virtualtext",
		virtualtext = "󱓻",
		virtualtext_inline = "before",
	},
})
