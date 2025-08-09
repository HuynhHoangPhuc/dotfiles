vim.loader.enable()
require("options")
require("keymaps")

if not os.getenv("DOTFILES_WITH_FLAKE") then
	require("plugins")
	require("packages").install_all()
end
