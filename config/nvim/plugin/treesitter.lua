require("packages.lazy").add({
	src = "https://github.com/nvim-treesitter/nvim-treesitter",
	config = function()
		local ensure_installed = {
			"lua",
			"c",
			"cpp",
			"html",
			"css",
			"javascript",
			"typescript",
			"tsx",
			"markdown",
			"markdown_inline",
			"zig",
			"rust",
			"ron",
		}

		local treesitter = require("nvim-treesitter")

		-- Listing installed parsers hits disk and installing them is slow, so
		-- neither belongs in front of the first redraw.
		vim.schedule(function()
			-- Without the "parsers" argument this also reports languages that only have
			-- queries installed, which hides parsers that never compiled.
			local installed = treesitter.get_installed("parsers")

			local missing = vim.iter(ensure_installed)
				:filter(function(lang)
					return not vim.tbl_contains(installed, lang)
				end)
				:totable()

			if #missing == 0 then return end

			local spawn_ok, task = pcall(treesitter.install, missing)

			if not spawn_ok then
				vim.notify(
					"nvim-treesitter parser install failed to start: " .. tostring(task),
					vim.log.levels.WARN
				)
				return
			end

			-- Compilation runs asynchronously: a failing "tree-sitter build"
			-- resolves through this callback, not as a pcall error. Reporting it
			-- here is what keeps a silent failure from reinstalling every startup.
			task:await(function(err, success)
				if err or not success then
					vim.schedule(function()
						vim.notify(
							"nvim-treesitter parser install failed: "
								.. tostring(err or "tree-sitter CLI missing or build error"),
							vim.log.levels.WARN
						)
					end)
				end
			end)
		end)

		local uv = vim.uv or vim.loop

		local function is_large_file(buf)
			local max_filesize = 100 * 1024 -- 100 KB
			local ok_stat, stats = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(buf))

			return ok_stat and stats and stats.size > max_filesize
		end

		local group = vim.api.nvim_create_augroup("dotfiles-treesitter", { clear = true })

		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			callback = function(args)
				if is_large_file(args.buf) then return end

				pcall(vim.treesitter.start, args.buf)
			end,
		})
	end,
})
