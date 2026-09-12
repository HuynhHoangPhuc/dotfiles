require("packages.lazy").add({
	src = "https://github.com/kylechui/nvim-surround",
	event = "BufReadPre",
	config = function()
		require("nvim-surround").setup()
	end,
})
