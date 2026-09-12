-- Configured from lua/languages/clang.lua, which sets it up when clangd
-- attaches. Registered here only so the filetype decides when it loads.
require("packages.lazy").add({
	src = "https://github.com/p00f/clangd_extensions.nvim",
	ft = { "c", "cpp", "objc", "objcpp", "cuda" },
})
