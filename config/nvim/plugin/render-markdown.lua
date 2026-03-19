local ok, render_md = pcall(require, "render-markdown")
if not ok then
	return
end

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

-- Toggle render-markdown with <leader>um
vim.keymap.set("n", "<leader>um", function()
	render_md.toggle()
end, { desc = "Toggle Render Markdown" })
