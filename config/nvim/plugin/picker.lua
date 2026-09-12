local lazy = require("packages.lazy")

lazy.add({ src = "https://github.com/nvim-lua/plenary.nvim", lazy = true })
lazy.add({ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim", lazy = true })

local function visual_selection()
	return table.concat(
		vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() }),
		"\n"
	)
end

local function builtin()
	return require("telescope.builtin")
end

lazy.add({
	src = "https://github.com/nvim-telescope/telescope.nvim",
	deps = { "plenary.nvim", "telescope-ui-select.nvim", "nvim-web-devicons" },
	cmd = "Telescope",
	keys = {
		{
			"<C-p>",
			function()
				builtin().find_files()
			end,
			desc = "Find files",
		},
		{
			"<C-S-p>",
			function()
				builtin().git_files()
			end,
			desc = "Find git files",
		},
		{
			"<C-\\>",
			function()
				builtin().buffers({ sort_mru = true, sort_lastused = true })
			end,
			desc = "Buffers",
		},
		{
			"<C-g>",
			function()
				builtin().live_grep()
			end,
			desc = "Live grep",
		},
		{
			"<C-f>",
			function()
				builtin().grep_string({ word_match = "-w" })
			end,
			desc = "Grep word under cursor",
		},
		{
			"<C-S-f>",
			function()
				builtin().grep_string({ search = vim.fn.expand("<cWORD>") })
			end,
			desc = "Grep WORD under cursor",
		},
		{
			"<C-f>",
			function()
				builtin().grep_string({ search = visual_selection() })
			end,
			mode = "x",
			desc = "Grep selection",
		},
		{
			"<leader>sb",
			function()
				builtin().current_buffer_fuzzy_find()
			end,
			desc = "Search buffer",
		},
		{
			"<leader>gc",
			function()
				builtin().git_commits()
			end,
			desc = "Git commits",
		},
		{
			"<leader>gs",
			function()
				builtin().git_status()
			end,
			desc = "Git status",
		},
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		-- Reopen a picker with different flags, carrying the typed query across.
		local function restart_with(picker, extra)
			return function(prompt_bufnr)
				local line = action_state.get_current_line()
				actions.close(prompt_bufnr)
				picker(vim.tbl_extend("force", extra or {}, { default_text = line }))
			end
		end

		telescope.setup({
			defaults = {
				prompt_prefix = " ",
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
							["<M-h>"] = restart_with(builtin().find_files, { hidden = true }),
							["<M-i>"] = restart_with(builtin().find_files, { no_ignore = true }),
						},
					},
				},
				live_grep = {
					mappings = {
						i = {
							["<M-h>"] = restart_with(
								builtin().live_grep,
								{ additional_args = { "--hidden" } }
							),
							["<M-i>"] = restart_with(
								builtin().live_grep,
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
	end,
})

-- telescope-ui-select takes over vim.ui.select when the extension loads, so
-- this stub only has to survive until something first asks to select.
local stub
local fallback = vim.ui.select

stub = function(items, opts, on_choice)
	lazy.load("telescope.nvim")

	-- Telescope failed to load, or the extension did not take over. Restore the
	-- default rather than recurse straight back into this stub.
	if vim.ui.select == stub then rawset(vim.ui, "select", fallback) end

	return vim.ui.select(items, opts, on_choice)
end

-- rawset avoids lua_ls duplicate-set-field on the stubbed vim.ui.select.
rawset(vim.ui, "select", stub)
