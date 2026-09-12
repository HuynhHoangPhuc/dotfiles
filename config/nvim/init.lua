vim.loader.enable()
require("options")
require("keymaps")

if not os.getenv("DOTFILES_WITH_FLAKE") then
	require("plugins")
	require("packages").setup()
end

if vim.fn.has("win32") == 1 then
	-- Detects if the current shell is bash
	if string.find(vim.o.shell, "bash") or string.find(vim.o.shell, "sh") then
		vim.o.shellcmdflag = "-c"
		vim.o.shellxquote = ""
	end
end
