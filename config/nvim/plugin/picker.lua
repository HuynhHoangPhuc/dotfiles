-- local fzf = require("fzf-lua")
-- local config = fzf.config
-- local actions = fzf.actions
--
-- -- Quickfix
-- config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
-- config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
-- config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
-- config.defaults.keymap.fzf["ctrl-x"] = "jump"
-- config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
-- config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
-- config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
-- config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"
--
-- fzf.setup({
--   { "default-title" },
--   files = {
--     cwd_prompt = false,
--     actions = {
--       ["alt-i"] = { actions.toggle_ignore },
--       ["alt-h"] = { actions.toggle_hidden },
--     },
--   },
--   grep = {
--     actions = {
--       ["alt-i"] = { actions.toggle_ignore },
--       ["alt-h"] = { actions.toggle_hidden },
--     },
--   },
-- })
--
-- require("fzf-lua").register_ui_select(function(fzf_opts, items)
--   return vim.tbl_deep_extend("force", fzf_opts, {
--     prompt = " ",
--     winopts = {
--       title = " " .. vim.trim(
--         (fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")
--       ) .. " ",
--       title_pos = "center",
--     },
--   }, fzf_opts.kind == "codeaction" and {
--     winopts = {
--       layout = "vertical",
--       -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
--       height = math.floor(
--         math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5
--       ) + 16,
--       width = 0.5,
--       preview = not vim.tbl_isempty(
--         vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })
--       ) and {
--         layout = "vertical",
--         vertical = "down:15,border-top",
--         hidden = "hidden",
--       } or {
--         layout = "vertical",
--         vertical = "down:15,border-top",
--       },
--     },
--   } or {
--     winopts = {
--       width = 0.5,
--       -- height is number of items, with a max of 80% screen height
--       height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
--     },
--   })
-- end)
--
-- vim.keymap.set("n", "<C-p>", "<cmd>FzfLua files<cr>")
-- vim.keymap.set("n", "<C-S-p>", "<cmd>FzfLua git_files<cr>")
-- vim.keymap.set(
--   "n",
--   "<C-\\>",
--   "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>"
-- )
-- vim.keymap.set("n", "<C-g>", "<cmd>FzfLua live_grep<cr>")
-- vim.keymap.set("n", "<C-f>", "<cmd>FzfLua grep_cword<cr>")
-- vim.keymap.set("n", "<C-S-f>", "<cmd>FzfLua grep_cWORD<cr>")
-- vim.keymap.set("v", "<C-f>", "<cmd>FzfLua grep_visual<cr>")
-- vim.keymap.set("n", "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>")
-- vim.keymap.set("n", "<leader>gc", "<cmd>FzfLua git_commits<cr>")
-- vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<cr>")

--[[
local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")

local function choose_all_to_qf()
	local matches = MiniPick.get_picker_matches()
	if matches == nil or matches.all == nil or #matches.all == 0 then
		return true
	end
	MiniPick.default_choose_marked(matches.all)
	return true
end

local function show_paths(buf_id, items, query)
	MiniPick.default_show(buf_id, items, query, { show_icons = true })
end

local function pick_files(opts)
	opts = opts or {}
	local hidden = opts.hidden or false
	local no_ignore = opts.no_ignore or false

	local name = "Files"
	local command = { "rg", "--files", "--color=never" }
	if hidden then
		name = name .. " hidden"
		table.insert(command, "--hidden")
	end
	if no_ignore then
		name = name .. " no-ignore"
		table.insert(command, "--no-ignore")
	end

	local mappings = {
		toggle_hidden = {
			char = "<M-h>",
			func = function()
				pick_files({ hidden = not hidden, no_ignore = no_ignore })
			end,
		},
		toggle_ignore = {
			char = "<M-i>",
			func = function()
				pick_files({ hidden = hidden, no_ignore = not no_ignore })
			end,
		},
	}

	if not hidden and not no_ignore then
		MiniPick.builtin.files({}, {
			source = { name = name },
			mappings = mappings,
		})
		return
	end

	MiniPick.builtin.cli({ command = command }, {
		source = { name = name, show = show_paths },
		mappings = mappings,
	})
end

local function visual_selection()
	return table.concat(
		vim.fn.getregion(
			vim.fn.getpos("v"),
			vim.fn.getpos("."),
			{ type = vim.fn.mode() }
		),
		"\n"
	)
end

local function pick_git_status()
	MiniPick.builtin.cli({
		command = { "git", "status", "--short", "--untracked-files=all" },
		postprocess = function(lines)
			local items = {}
			for _, line in ipairs(lines) do
				if line ~= "" then
					local path = line:match("->%s+(.+)$")
						or line:match("^..%s+(.*)$")
					table.insert(items, { text = line, path = path or line })
				end
			end
			return items
		end,
	}, { source = { name = "Git status" } })
end

MiniPick.setup({
	mappings = {
		scroll_down = "<C-d>",
		scroll_up = "<C-u>",
		delete_left = "<C-b>",
		mark = "<C-x>",
		choose_quickfix = { char = "<C-q>", func = choose_all_to_qf },
	},
	window = {
		prompt_prefix = " ",
	},
})

MiniExtra.setup()

-- MiniPick.setup() already sets vim.ui.select; wrap it for popup size.
-- rawset avoids lua_ls duplicate-set-field on the stubbed vim.ui.select.
rawset(vim.ui, "select", function(items, opts, on_choice)
	local height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5)
	return MiniPick.ui_select(items, opts, on_choice, {
		window = {
			config = {
				width = math.floor(0.5 * vim.o.columns),
				height = height,
			},
		},
	})
end)

vim.keymap.set("n", "<C-p>", pick_files)
vim.keymap.set("n", "<C-S-p>", function()
	MiniExtra.pickers.git_files()
end)
vim.keymap.set("n", "<C-\\>", function()
	MiniPick.builtin.buffers()
end)
vim.keymap.set("n", "<C-g>", function()
	MiniPick.builtin.grep_live()
end)
vim.keymap.set("n", "<C-f>", function()
	MiniPick.builtin.grep({
		pattern = vim.fn.expand("<cword>"),
		method = "plain",
	})
end)
vim.keymap.set("n", "<C-S-f>", function()
	MiniPick.builtin.grep({
		pattern = vim.fn.expand("<cWORD>"),
		method = "plain",
	})
end)
vim.keymap.set("x", "<C-f>", function()
	MiniPick.builtin.grep({
		pattern = visual_selection(),
		method = "plain",
	})
end)
vim.keymap.set("n", "<leader>sb", function()
	MiniExtra.pickers.buf_lines({ scope = "current" })
end)
vim.keymap.set("n", "<leader>gc", function()
	MiniExtra.pickers.git_commits()
end)
vim.keymap.set("n", "<leader>gs", pick_git_status)
]]

local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function visual_selection()
	return table.concat(
		vim.fn.getregion(
			vim.fn.getpos("v"),
			vim.fn.getpos("."),
			{ type = vim.fn.mode() }
		),
		"\n"
	)
end

local function restart_with(picker, extra)
	return function(prompt_bufnr)
		local line = action_state.get_current_line()
		actions.close(prompt_bufnr)
		picker(vim.tbl_extend("force", extra or {}, { default_text = line }))
	end
end

telescope.setup({
	defaults = {
		prompt_prefix = " ",
		mappings = {
			i = {
				["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,
				["<C-b>"] = actions.preview_scrolling_up,
				["<C-f>"] = actions.preview_scrolling_down,
			},
			n = {
				["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
			},
		},
	},
	pickers = {
		find_files = {
			mappings = {
				i = {
					["<M-h>"] = restart_with(builtin.find_files, { hidden = true }),
					["<M-i>"] = restart_with(
						builtin.find_files,
						{ no_ignore = true }
					),
				},
			},
		},
		live_grep = {
			mappings = {
				i = {
					["<M-h>"] = restart_with(
						builtin.live_grep,
						{ additional_args = { "--hidden" } }
					),
					["<M-i>"] = restart_with(
						builtin.live_grep,
						{ additional_args = { "--no-ignore" } }
					),
				},
			},
		},
		buffers = {
			sort_mru = true,
			sort_lastused = true,
		},
	},
	extensions = {
		["ui-select"] = require("telescope.themes").get_dropdown({
			layout_config = { width = 0.5 },
		}),
	},
})

pcall(telescope.load_extension, "ui-select")

vim.keymap.set("n", "<C-p>", builtin.find_files)
vim.keymap.set("n", "<C-S-p>", builtin.git_files)
vim.keymap.set("n", "<C-\\>", function()
	builtin.buffers({ sort_mru = true, sort_lastused = true })
end)
vim.keymap.set("n", "<C-g>", builtin.live_grep)
vim.keymap.set("n", "<C-f>", function()
	builtin.grep_string({ word_match = "-w" })
end)
vim.keymap.set("n", "<C-S-f>", function()
	builtin.grep_string({ search = vim.fn.expand("<cWORD>") })
end)
vim.keymap.set("x", "<C-f>", function()
	builtin.grep_string({ search = visual_selection() })
end)
vim.keymap.set("n", "<leader>sb", builtin.current_buffer_fuzzy_find)
vim.keymap.set("n", "<leader>gc", builtin.git_commits)
vim.keymap.set("n", "<leader>gs", builtin.git_status)
