local M = {}

M.lsp = {
	servers = {
		clangd = {
			capabilities = {
				offsetEncoding = { "utf-16" },
			},
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--header-insertion=iwyu",
				"--completion-style=detailed",
				"--function-arg-placeholders",
				"--fallback-style=llvm",
			},
			init_options = {
				usePlaceholders = true,
				completeUnimported = true,
				clangdFileStatus = true,
			},
		},
	},
	setup = {
		clangd = function()
			require("clangd_extensions").setup({
				inlay_hints = {
					inline = false,
				},
				ast = {
					role_icons = {
						type = "",
						declaration = "",
						expression = "",
						specifier = "",
						statement = "",
						["template argument"] = "",
					},
					kind_icons = {
						Compound = "",
						Recovery = "",
						TranslationUnit = "",
						PackExpansion = "",
						TemplateTypeParm = "",
						TemplateTemplateParm = "",
						TemplateParamObject = "",
					},
				},
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "c", "cpp" },
				callback = function(args)
					vim.keymap.set(
						"n",
						"<F10>",
						"<cmd>ClangdSwitchSourceHeader<cr>",
						{ buffer = args.buf }
					)
				end,
			})
		end,
	},
}

return M
