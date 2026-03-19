-- Install app dependencies if missing
local plugin_path = vim.fn.globpath(vim.o.packpath, "pack/*/opt/markdown-preview.nvim")
if plugin_path ~= "" and vim.fn.isdirectory(plugin_path .. "/app/node_modules") == 0 then
	vim.fn.system(
		"cd " .. vim.fn.shellescape(plugin_path) .. "/app && npx --yes yarn install"
	)
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("markdown-preview", { clear = true }),
	pattern = "markdown",
	callback = function()
		vim.keymap.set("n", "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", {
			buffer = true,
			desc = "Markdown Preview",
		})
	end,
})
