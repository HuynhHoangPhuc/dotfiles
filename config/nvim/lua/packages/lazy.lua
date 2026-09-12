-- Minimal lazy-loading layer over vim.pack.
--
-- Namespaced under packages/ rather than sitting at lua/lazy.lua: plugins probe
-- for lazy.nvim by requiring "lazy.core.config", and a top-level `lazy` module
-- makes that probe succeed against the wrong thing.
--
-- vim.pack installs everything into pack/core/opt, so "lazy" here only means
-- withholding the `:packadd` until a trigger fires. Specs are registered from
-- plugin/*.lua, which Neovim sources unconditionally at startup; registering a
-- spec only builds a table, so the require + setup cost stays inside
-- `spec.config` until the plugin is actually needed.

---@class LazySpec
---@field src string Plugin URL, handed to vim.pack.
---@field name? string Directory under pack/core/opt. Defaults to the last segment of `src`.
---@field version? string|vim.VersionRange Passed through to vim.pack.
---@field ft? string|string[] Load on FileType.
---@field event? string|string[] Load on the first of these events.
---@field cmd? string|string[] Load when one of these commands is first run.
---@field keys? table[] `{ lhs, rhs, mode?, desc? }`; `rhs` runs once the plugin is loaded.
---@field deps? string[] Names of specs to load first.
---@field lazy? boolean Install, but only load when something else asks for it.
---@field config? fun() Runs immediately after the plugin joins the session.

local M = {}

local specs = {} ---@type table<string, LazySpec>
local pending = {} ---@type vim.pack.Spec[]
local loaded = {} ---@type table<string, true>
local flushed = false

local group = vim.api.nvim_create_augroup("lazy", { clear = true })

local function as_list(value)
	if value == nil then return {} end
	return type(value) == "table" and value or { value }
end

local function pack_spec(spec)
	return { src = spec.src, name = spec.name, version = spec.version }
end

local function report(name, what, err)
	vim.notify(("lazy: %s %s: %s"):format(name, what, err), vim.log.levels.ERROR)
end

-- One batched vim.pack.add for every lazy spec. On a fresh machine that clones
-- them in parallel behind a single wait, rather than one blocking clone per
-- plugin/*.lua file.
local function flush()
	if flushed then return end
	flushed = true

	if #pending == 0 then return end

	local ok, err = pcall(vim.pack.add, pending, { load = false })
	if not ok then report("install", "failed", err) end

	pending = {}
end

-- `:packadd` sources a plugin's plugin/ directory but never its after/plugin
-- one. vim.pack.add compensates for that itself, so loading by hand has to as
-- well -- see the same workaround in runtime/lua/vim/pack.lua.
local function source_after(name)
	local dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt", name)

	for _, file in ipairs(vim.fn.glob(dir .. "/after/plugin/**/*.{vim,lua}", false, true)) do
		pcall(vim.cmd.source, file)
	end
end

local function configure(name, spec)
	if not spec.config then return end

	local ok, err = pcall(spec.config)
	if not ok then report(name, "config", err) end
end

--- Add a registered plugin to the session, along with anything it depends on.
--- Safe to call repeatedly; only the first call does any work.
---@param name string
function M.load(name)
	if loaded[name] then return end

	local spec = specs[name]
	if not spec then
		vim.notify("lazy: no spec registered for " .. name, vim.log.levels.WARN)
		return
	end

	-- Set before the dependency walk so a cycle terminates instead of recursing.
	loaded[name] = true
	flush()

	for _, dep in ipairs(spec.deps or {}) do
		M.load(dep)
	end

	local ok, err = pcall(vim.cmd.packadd, name)
	if not ok then return report(name, "packadd", err) end

	-- Unconditional, unlike the check vim.pack.add makes: Neovim scans after/
	-- once it has sourced every plugin/ script, which is before it so much as
	-- opens the file named on the command line. So any trigger that can reach
	-- here -- BufReadPre at the earliest -- has already missed that scan.
	source_after(name)

	configure(name, spec)
end

local function on_ft(name, filetypes)
	local id
	id = vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = filetypes,
		callback = function(args)
			vim.api.nvim_del_autocmd(id)
			M.load(name)

			-- The plugin's ftplugin/ never ran for this buffer, since it only
			-- reached the runtimepath midway through the event. Re-firing lets it
			-- catch up, and the autocmd above is already gone, so this can't loop.
			vim.api.nvim_buf_call(args.buf, function()
				vim.api.nvim_exec_autocmds("FileType", { pattern = args.match, modeline = false })
			end)
		end,
	})
end

-- No re-fire here, unlike FileType: these plugins all pick up already-open
-- buffers in their own setup(), and BufReadPre lands before the file is read.
local function on_event(name, events)
	local id
	id = vim.api.nvim_create_autocmd(events, {
		group = group,
		callback = function()
			vim.api.nvim_del_autocmd(id)
			M.load(name)
		end,
	})
end

local function on_cmd(name, cmds)
	for _, cmd in ipairs(cmds) do
		vim.api.nvim_create_user_command(cmd, function(args)
			-- Drop the stub before loading, so the real command can take the name.
			vim.api.nvim_del_user_command(cmd)
			M.load(name)

			vim.cmd({
				cmd = cmd,
				args = args.fargs,
				bang = args.bang,
				-- nil, not {}: the key being present at all is what makes vim.cmd
				-- reject a real command that was defined without -range.
				range = args.range > 0 and { args.line1, args.line2 } or nil,
				mods = args.smods,
			})
		end, { nargs = "*", range = true, bang = true, complete = "file" })
	end
end

-- The mapping is real from the start, so there is nothing to replay: loading
-- first and calling through covers the keypress that triggered it. A config()
-- that maps the same key just takes over from the next press on.
local function on_keys(name, keys)
	for _, key in ipairs(keys) do
		local rhs = key[2]

		vim.keymap.set(key.mode or "n", key[1], function()
			M.load(name)
			rhs()
		end, { desc = key.desc })
	end
end

--- Register a plugin. A spec with no trigger loads immediately.
---@param spec LazySpec
function M.add(spec)
	spec.name = spec.name or spec.src:match("([^/]+)$")

	local name = spec.name
	specs[name] = spec

	local filetypes, events = as_list(spec.ft), as_list(spec.event)
	local cmds, keys = as_list(spec.cmd), spec.keys or {}
	local triggers = #filetypes + #events + #cmds + #keys

	if triggers == 0 and not spec.lazy then
		-- Eager, and deliberately not batched: a colorscheme has to be in effect
		-- before the first redraw, not at VimEnter.
		loaded[name] = true

		local ok, err = pcall(vim.pack.add, { pack_spec(spec) })
		if not ok then return report(name, "install", err) end

		return configure(name, spec)
	end

	pending[#pending + 1] = pack_spec(spec)

	if #filetypes > 0 then on_ft(name, filetypes) end
	if #events > 0 then on_event(name, events) end
	if #cmds > 0 then on_cmd(name, cmds) end
	if #keys > 0 then on_keys(name, keys) end
end

-- Nothing may have triggered by now, but the plugins should still be on disk.
vim.api.nvim_create_autocmd("VimEnter", { group = group, once = true, callback = flush })

vim.api.nvim_create_user_command("Plugins", function()
	local names = vim.tbl_keys(specs)
	table.sort(names)

	local lines = vim.tbl_map(function(name)
		return ("%s %s"):format(loaded[name] and "●" or "○", name)
	end, names)

	vim.notify(table.concat(lines, "\n"))
end, { desc = "List registered plugins and whether they are loaded" })

--- Plugins on disk that no plugin/*.lua asks for any more. vim.pack installs
--- what a spec names but never removes what no spec names, so dropping a plugin
--- from the config just orphans its directory.
local function orphans()
	local found = {}

	for _, data in ipairs(vim.pack.get(nil, { info = false })) do
		-- Deliberately not data.active: lazy specs only become active at the
		-- VimEnter flush, so every plugin still waiting on its trigger would look
		-- orphaned. The registry above is authoritative as soon as plugin/ has
		-- been sourced, which is well before anyone can run this.
		if not specs[data.spec.name] then found[#found + 1] = data.spec.name end
	end

	table.sort(found)

	return found
end

vim.api.nvim_create_user_command("PluginsClean", function(opts)
	local found = orphans()

	if #found == 0 then
		vim.notify("No orphaned plugins")
		return
	end

	local prompt = ("Remove %d orphaned plugin(s)?\n%s"):format(#found, table.concat(found, "\n"))

	if not opts.bang and vim.fn.confirm(prompt, "&Yes\n&No", 2) ~= 1 then return end

	vim.pack.del(found)
end, { bang = true, desc = "Remove plugins on disk that no spec asks for (! skips the prompt)" })

return M
