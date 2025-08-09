local fzf = require("fzf-lua")
local config = fzf.config
local actions = fzf.actions

-- Quickfix
config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
config.defaults.keymap.fzf["ctrl-x"] = "jump"
config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

fzf.setup({
	{ "default-title" },
	files = {
		cwd_prompt = false,
		actions = {
			["alt-i"] = { actions.toggle_ignore },
			["alt-h"] = { actions.toggle_hidden },
		},
	},
	grep = {
		actions = {
			["alt-i"] = { actions.toggle_ignore },
			["alt-h"] = { actions.toggle_hidden },
		},
	},
})

require("fzf-lua").register_ui_select(function(fzf_opts, items)
	return vim.tbl_deep_extend("force", fzf_opts, {
		prompt = " ",
		winopts = {
			title = " " .. vim.trim(
				(fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")
			) .. " ",
			title_pos = "center",
		},
	}, fzf_opts.kind == "codeaction" and {
		winopts = {
			layout = "vertical",
			-- height is number of items minus 15 lines for the preview, with a max of 80% screen height
			height = math.floor(
				math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5
			) + 16,
			width = 0.5,
			preview = not vim.tbl_isempty(
				vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })
			) and {
				layout = "vertical",
				vertical = "down:15,border-top",
				hidden = "hidden",
			} or {
				layout = "vertical",
				vertical = "down:15,border-top",
			},
		},
	} or {
		winopts = {
			width = 0.5,
			-- height is number of items, with a max of 80% screen height
			height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
		},
	})
end)

vim.keymap.set("n", "<C-p>", "<cmd>FzfLua files<cr>")
vim.keymap.set("n", "<C-S-p>", "<cmd>FzfLua git_files<cr>")
vim.keymap.set(
	"n",
	"<C-\\>",
	"<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>"
)
vim.keymap.set("n", "<C-/>", "<cmd>FzfLua live_grep<cr>")
vim.keymap.set("n", "<C-f>", "<cmd>FzfLua grep_cword<cr>")
vim.keymap.set("n", "<C-S-f>", "<cmd>FzfLua grep_cWORD<cr>")
vim.keymap.set("v", "<C-f>", "<cmd>FzfLua grep_visual<cr>")
vim.keymap.set("n", "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>")
vim.keymap.set("n", "<leader>gc", "<cmd>FzfLua git_commits<cr>")
vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<cr>")
