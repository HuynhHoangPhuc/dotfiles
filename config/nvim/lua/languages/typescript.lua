local M = {}

local function execute(opts)
	local params = {
		command = opts.command,
		arguments = opts.arguments,
	}
	if opts.open then
		require("trouble").open({
			mode = "lsp_command",
			params = params,
		})
	else
		return vim.lsp.buf_request(
			0,
			"workspace/executeCommand",
			params,
			opts.handler
		)
	end
end

M.lsp = {
	servers = {
		vtsls = {
			-- explicitly add default filetypes, so that we can extend
			-- them in related extras
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
			},
			settings = {
				complete_function_calls = true,
				vtsls = {
					enableMoveToFileCodeAction = true,
					autoUseWorkspaceTsdk = true,
					experimental = {
						maxInlayHintLength = 30,
						completion = {
							enableServerSideFuzzyMatch = true,
						},
					},
				},
				typescript = {
					updateImportsOnFileMove = { enabled = "always" },
					suggest = {
						completeFunctionCalls = true,
					},
					inlayHints = {
						enumMemberValues = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						parameterNames = { enabled = "literals" },
						parameterTypes = { enabled = true },
						propertyDeclarationTypes = { enabled = true },
						variableTypes = { enabled = false },
					},
				},
			},
		},
		eslint = {
			settings = {
				-- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
				workingDirectories = { mode = "auto" },
				format = true,
			},
		},
	},
	setup = {
		vtsls = function(_, opts)
			vim.api.nvim_create_autocmd("LspAttach", {
				pattern = {
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"astro",
				},
				callback = function(args)
					vim.keymap.set("n", "grD", function()
						local params =
							vim.lsp.util.make_position_params(0, "utf-8")
						execute({
							command = "typescript.goToSourceDefinition",
							arguments = {
								params.textDocument.uri,
								params.position,
							},
							open = false,
						})
					end, {
						buffer = args.buf,
						desc = "Goto Source Definition",
					})

					vim.keymap.set("n", "gR", function()
						execute({
							command = "typescript.findAllFileReferences",
							arguments = { vim.uri_from_bufnr(0) },
							open = false,
						})
					end, { buffer = args.buf, desc = "File References" })

					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client or client.name ~= "vtsls" then
						return
					end

					-- client.commands["_typescript.moveToFileRefactoring"] = function(
					-- 	command,
					-- 	ctx
					-- )
					-- 	---@type string, string, lsp.Range
					-- 	local action, uri, range = unpack(command.arguments)
					--
					-- 	local function move(newf)
					-- 		client.request("workspace/executeCommand", {
					-- 			command = command.command,
					-- 			arguments = { action, uri, range, newf },
					-- 		})
					-- 	end
					--
					-- 	local fname = vim.uri_to_fname(uri)
					-- 	client.request("workspace/executeCommand", {
					-- 		command = "typescript.tsserverRequest",
					-- 		arguments = {
					-- 			"getMoveToRefactoringFileSuggestions",
					-- 			{
					-- 				file = fname,
					-- 				startLine = range.start.line + 1,
					-- 				startOffset = range.start.character + 1,
					-- 				endLine = range["end"].line + 1,
					-- 				endOffset = range["end"].character + 1,
					-- 			},
					-- 		},
					-- 	}, function(_, result)
					-- 		---@type string[]
					-- 		local files = result.body.files
					-- 		table.insert(files, 1, "Enter new path...")
					-- 		vim.ui.select(files, {
					-- 			prompt = "Select move destination:",
					-- 			format_item = function(f)
					-- 				return vim.fn.fnamemodify(f, ":~:.")
					-- 			end,
					-- 		}, function(f)
					-- 			if f and f:find("^Enter new path") then
					-- 				vim.ui.input({
					-- 					prompt = "Enter move destination:",
					-- 					default = vim.fn.fnamemodify(
					-- 						fname,
					-- 						":h"
					-- 					) .. "/",
					-- 					completion = "file",
					-- 				}, function(newf)
					-- 					return newf and move(newf)
					-- 				end)
					-- 			elseif f then
					-- 				move(f)
					-- 			end
					-- 		end)
					-- 	end)
					-- end
				end,
			})

			opts.settings.javascript = vim.tbl_deep_extend(
				"force",
				{},
				opts.settings.typescript,
				opts.settings.javascript or {}
			)
		end,
	},
}

M.format = {
	formatters_by_ft = {
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
	},
	-- formatters = {
	-- 	biome = {
	-- 		args = {
	-- 			"format",
	-- 			"--indent-style=space",
	-- 			"--indent-width=4",
	-- 			"--stdin-file-path",
	-- 			"$FILENAME",
	-- 		},
	-- 	},
	-- },
}

-- M.lint = {
-- 	linters_by_ft = {
-- 		javascript = { "biomejs" },
-- 		javascriptreact = { "biomejs" },
-- 		typescript = { "biomejs" },
-- 		typescriptreact = { "biomejs" },
-- 	},
-- }

return M
