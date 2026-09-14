-- Eager: setup() is what puts mason's bin directory on PATH, and servers start
-- at BufReadPre, before anything deferred to the event loop gets a turn.
require("packages.lazy").add({
	src = "https://github.com/mason-org/mason.nvim",
	config = function()
		require("mason").setup()

		-- Walking the registry is the expensive half of this, and nothing on screen
		-- depends on the result. Scheduled from here rather than init.lua: queued any
		-- earlier, it can fire inside vim.pack's first-install confirm() prompt,
		-- before mason is on disk, and the error aborts the whole install.
		vim.schedule(require("packages").install_missing)
	end,
})
