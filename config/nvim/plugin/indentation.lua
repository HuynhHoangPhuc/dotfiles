require("packages.lazy").add({
	src = "https://github.com/lukas-reineke/indent-blankline.nvim",
	event = "BufReadPre",
	config = function()
		require("ibl").setup({
			indent = { char = "▏" },
			scope = { char = "▏" },
		})
	end,
})
