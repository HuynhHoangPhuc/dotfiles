require("packages.lazy").add({
	src = "https://github.com/windwp/nvim-ts-autotag",
	ft = {
		"html",
		"xml",
		"javascriptreact",
		"typescriptreact",
		"astro",
		"vue",
		"svelte",
	},
	config = function()
		require("nvim-ts-autotag").setup()
	end,
})
