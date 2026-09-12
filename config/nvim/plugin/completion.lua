require("packages.lazy").add({
	src = "https://github.com/saghen/blink.cmp",
	version = vim.version.range("1.*"),
	-- Not InsertEnter: plugin/languageserver.lua needs get_lsp_capabilities()
	-- before it can configure any server, so blink has to exist by then.
	event = "BufReadPre",
	deps = { "friendly-snippets" },
	config = function()
		require("blink.cmp").setup({
			keymap = {
				preset = "enter",
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					lsp = {
						min_keyword_length = 0,
						score_offset = 0,
					},
					path = {
						min_keyword_length = 0,
					},
					snippets = {
						min_keyword_length = 2,
					},
					buffer = {
						min_keyword_length = 5,
						max_items = 5,
					},
					cmdline = {
						min_keyword_length = 3,
					},
				},
			},
			completion = {
				accept = { auto_brackets = { enabled = true } },

				keyword = {
					range = "full",
				},

				trigger = {
					show_on_insert_on_trigger_character = true,
					show_on_trigger_character = true,
					show_on_keyword = true,
				},

				documentation = {
					auto_show = true,
					auto_show_delay_ms = 250,
					treesitter_highlighting = true,
				},
			},
		})
	end,
})
