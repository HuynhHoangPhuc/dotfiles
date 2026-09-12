require("packages.lazy").add({
	src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },
	config = function()
		local render_md = require("render-markdown")

		render_md.setup({
			code = {
				sign = false,
				width = "block",
				right_pad = 1,
			},
			heading = {
				sign = false,
				icons = {},
			},
			checkbox = {
				enabled = false,
			},
		})

		vim.keymap.set("n", "<leader>um", function()
			render_md.toggle()
		end, { desc = "Toggle Render Markdown" })
	end,
})
