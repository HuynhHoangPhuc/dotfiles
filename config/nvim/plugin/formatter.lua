require("conform").setup(require("languageconfigs").format)

-- Use conform for gq.
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

-- Start auto-formatting by default (and disable with my ToggleFormat command).
vim.g.autoformat = true
