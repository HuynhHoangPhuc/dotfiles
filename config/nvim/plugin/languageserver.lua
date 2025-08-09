local configs = require("languageconfigs")

local function on_attach(client, bufnr)
	local map = function(keys, func, desc, mode)
		mode = mode or "n"
		vim.keymap.set(
			mode,
			keys,
			func,
			{ buffer = bufnr, desc = "LSP: " .. desc }
		)
	end
	local methods = vim.lsp.protocol.Methods

	map(
		"gra",
		"<cmd>FzfLua lsp_code_actions<cr>",
		"vim.lsp.buf.code_action()",
		{ "n", "x" }
	)
	map("grr", "<cmd>FzfLua lsp_references<cr>", "vim.lsp.buf.references()")
	map(
		"gri",
		"<cmd>FzfLua lsp_implementations<cr>",
		"vim.lsp.buf.implementation()"
	)
	map(
		"gO",
		"<cmd>FzfLua lsp_document_symbols<cr>",
		"vim.lsp.buf.document_symbol()"
	)

	map("[e", function()
		vim.diagnostic.jump({
			count = -1,
			severity = vim.diagnostic.severity.ERROR,
		})
	end, "Previous error")
	map("]e", function()
		vim.diagnostic.jump({
			count = 1,
			severity = vim.diagnostic.severity.ERROR,
		})
	end, "Next error")

	if client:supports_method(methods.textDocument_definition) then
		map("gd", function()
			require("fzf-lua").lsp_definitions({ jump1 = true })
		end, "Go to definition")
		map("gD", function()
			require("fzf-lua").lsp_definitions({ jump1 = false })
		end, "Peek definition")
	end

	if client:supports_method(methods.textDocument_documentHighlight) then
		local under_cursor_highlights_group = vim.api.nvim_create_augroup(
			"mariasolos/cursor_highlights",
			{ clear = false }
		)
		vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
			group = under_cursor_highlights_group,
			desc = "Highlight references under the cursor",
			buffer = bufnr,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd(
			{ "CursorMoved", "InsertEnter", "BufLeave" },
			{
				group = under_cursor_highlights_group,
				desc = "Clear highlight references",
				buffer = bufnr,
				callback = vim.lsp.buf.clear_references,
			}
		)
	end

	if client:supports_method(methods.textDocument_inlayHint) then
		local inlay_hints_group = vim.api.nvim_create_augroup(
			"mariasolos/toggle_inlay_hints",
			{ clear = false }
		)

		if vim.g.inlay_hints then
			-- Initial inlay hint display.
			-- Idk why but without the delay inlay hints aren't displayed at the very start.
			vim.defer_fn(function()
				local mode = vim.api.nvim_get_mode().mode
				vim.lsp.inlay_hint.enable(
					mode == "n" or mode == "v",
					{ bufnr = bufnr }
				)
			end, 500)
		end

		vim.api.nvim_create_autocmd("InsertEnter", {
			group = inlay_hints_group,
			desc = "Enable inlay hints",
			buffer = bufnr,
			callback = function()
				if vim.g.inlay_hints then
					vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
				end
			end,
		})

		vim.api.nvim_create_autocmd("InsertLeave", {
			group = inlay_hints_group,
			desc = "Disable inlay hints",
			buffer = bufnr,
			callback = function()
				if vim.g.inlay_hints then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end,
		})
	end
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end

		on_attach(client, args.buf)
	end,
})

vim.diagnostic.config(vim.deepcopy(configs.lsp.diagnostics))

local capabilities =
	require("blink.cmp").get_lsp_capabilities(configs.lsp.capabilities, true)
vim.lsp.config("*", { capabilities = capabilities })

for server, config in pairs(configs.lsp.servers) do
	if configs.lsp.setup[server] then
		configs.lsp.setup[server](server, config)
	end

	vim.lsp.config(server, config)
	vim.lsp.enable(server)
end
