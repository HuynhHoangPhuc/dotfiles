-- Configured from lua/languages/csharp.lua, which routes a handful of LSP
-- handlers through it. Registered here only so the filetype decides when it
-- loads.
require("packages.lazy").add({
	src = "https://github.com/hoffs/omnisharp-extended-lsp.nvim",
	ft = { "cs" },
})
