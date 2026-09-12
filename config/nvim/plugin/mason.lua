-- Eager: setup() is what puts mason's bin directory on PATH, and servers start
-- at BufReadPre, before anything deferred to the event loop gets a turn.
require("packages.lazy").add({
	src = "https://github.com/mason-org/mason.nvim",
	config = function()
		require("mason").setup()
	end,
})
