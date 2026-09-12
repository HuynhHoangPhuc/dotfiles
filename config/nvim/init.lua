vim.loader.enable()
require("options")
require("keymaps")

-- Plugins register themselves from plugin/*.lua via lua/lazy.lua.
require("packages").setup()

if vim.fn.has("win32") == 1 then
	-- Detects if the current shell is bash
	if string.find(vim.o.shell, "bash") or string.find(vim.o.shell, "sh") then
		vim.o.shellcmdflag = "-c"
		vim.o.shellxquote = ""
	end
end
