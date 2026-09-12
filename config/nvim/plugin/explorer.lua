local ok, MiniFiles = pcall(require, "mini.files")
if not ok then return end

MiniFiles.setup({
	content = {
		filter = function(entry)
			return entry.name ~= ".git"
		end,
	},
})

vim.keymap.set("n", "<leader>e", function()
	if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0), true) end
end)
vim.keymap.set("n", "<leader>E", function()
	MiniFiles.open(vim.uv.cwd(), true)
end)

local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")
local autocmd = vim.api.nvim_create_autocmd
local uv = vim.uv or vim.loop

-- [gitRoot] = { time, map }. Keyed by repository, not by directory: one
-- `git status` covers every level mini.files can show, so every open window
-- (root -> ... -> leaf) is painted from the same snapshot. Never cleared on
-- close so reopening is instant; expiry is by TTL, plus explicit invalidation
-- after file actions/writes.
local cache = {}
local pending = {} -- [gitRoot] = list of callbacks waiting on an in-flight call
local generation = 0 -- bumped on invalidation, so a call started before it cannot write back
local CACHE_TTL = 10 -- seconds

-- Every mini.files buffer currently alive, so invalidation can repaint all of
-- them instead of only the focused one.
local trackedBufs = {}

local function normalize(path)
	return (vim.fs.normalize(path):gsub("/+$", ""))
end

local function isSymlink(path)
	local stat = uv.fs_lstat(path)
	return stat and stat.type == "link"
end

---@type table<string, {symbol: string, hlGroup: string}>
local symbolMap = {
	-- stylua: ignore start
	[" M"] = { symbol = "•",  hlGroup = "MiniDiffSignChange" }, -- modified in working dir
	[" D"] = { symbol = "-",  hlGroup = "MiniDiffSignDelete" }, -- deleted in working dir
	[" T"] = { symbol = "~",  hlGroup = "MiniDiffSignChange" }, -- typechange in working dir
	["M "] = { symbol = "✹",  hlGroup = "MiniDiffSignChange" }, -- modified in index
	["MM"] = { symbol = "≠",  hlGroup = "MiniDiffSignChange" }, -- modified in both
	["MD"] = { symbol = "✗",  hlGroup = "MiniDiffSignDelete" }, -- modified in index, deleted in worktree
	["A "] = { symbol = "+",  hlGroup = "MiniDiffSignAdd"    }, -- added to staging
	["AA"] = { symbol = "≈",  hlGroup = "MiniDiffSignAdd"    }, -- added in both
	["AM"] = { symbol = "⊕",  hlGroup = "MiniDiffSignChange" }, -- added in index, modified in worktree
	["AD"] = { symbol = "✗",  hlGroup = "MiniDiffSignDelete" }, -- added in index, deleted in worktree
	["D "] = { symbol = "-",  hlGroup = "MiniDiffSignDelete" }, -- deleted from staging
	["DD"] = { symbol = "‖",  hlGroup = "MiniDiffSignDelete" }, -- both deleted (unmerged)
	["R "] = { symbol = "→",  hlGroup = "MiniDiffSignChange" }, -- renamed in index
	["RM"] = { symbol = "→",  hlGroup = "MiniDiffSignChange" }, -- renamed, then modified
	["RD"] = { symbol = "✗",  hlGroup = "MiniDiffSignDelete" }, -- renamed, then deleted
	["C "] = { symbol = "→",  hlGroup = "MiniDiffSignChange" }, -- copied in index
	["T "] = { symbol = "~",  hlGroup = "MiniDiffSignChange" }, -- typechange in index
	["U "] = { symbol = "‖",  hlGroup = "MiniDiffSignChange" }, -- unmerged path
	["UU"] = { symbol = "⇄",  hlGroup = "MiniDiffSignAdd"    }, -- both modified (unmerged)
	["UA"] = { symbol = "⊕",  hlGroup = "MiniDiffSignAdd"    }, -- added by them (unmerged)
	["AU"] = { symbol = "⊕",  hlGroup = "MiniDiffSignAdd"    }, -- added by us (unmerged)
	["UD"] = { symbol = "✗",  hlGroup = "MiniDiffSignDelete" }, -- deleted by them (unmerged)
	["DU"] = { symbol = "✗",  hlGroup = "MiniDiffSignDelete" }, -- deleted by us (unmerged)
	["??"] = { symbol = "?",  hlGroup = "MiniDiffSignDelete" }, -- untracked
	["!!"] = { symbol = "",   hlGroup = "Comment"            }, -- ignored (no sign, dimmed color)
	-- stylua: ignore end
}

-- Per-code fallback so an unlisted combination still renders something sane
-- instead of collapsing to a generic "?" that looks like "untracked".
---@type table<string, {symbol: string, hlGroup: string}>
local fallbackMap = {
	-- stylua: ignore start
	M = { symbol = "•", hlGroup = "MiniDiffSignChange" },
	A = { symbol = "+", hlGroup = "MiniDiffSignAdd"    },
	D = { symbol = "-", hlGroup = "MiniDiffSignDelete" },
	R = { symbol = "→", hlGroup = "MiniDiffSignChange" },
	C = { symbol = "→", hlGroup = "MiniDiffSignChange" },
	T = { symbol = "~", hlGroup = "MiniDiffSignChange" },
	U = { symbol = "‖", hlGroup = "MiniDiffSignChange" },
	-- stylua: ignore end
}

local function lookupSymbol(status)
	return symbolMap[status]
		or fallbackMap[status:sub(1, 1)]
		or fallbackMap[status:sub(2, 2)]
		or { symbol = "?", hlGroup = "NonText" }
end

local function mapSymbols(status, is_symlink)
	local entry = lookupSymbol(status)
	if not is_symlink then return entry.symbol, entry.hlGroup end
	-- `sign_text` is capped at 2 display cells, so the symlink marker only
	-- prefixes symbols that leave room for it.
	local symbol = vim.fn.strdisplaywidth(entry.symbol) >= 2 and "↩" or ("↩" .. entry.symbol)
	return symbol, "MiniDiffSignDelete"
end

-- Directory a mini.files buffer is showing. `get_fs_entry` is the cheap path,
-- but it returns nil for an empty directory, so fall back to the buffer name
-- (mini.files names buffers `minifiles://<id>/<path>`).
local function getBufDir(buf_id)
	local entry = MiniFiles.get_fs_entry(buf_id, 1)
	if entry then return normalize(vim.fs.dirname(entry.path)) end
	local path = vim.api.nvim_buf_get_name(buf_id):match("^minifiles://%d+/(.*)$")
	return path and path ~= "" and normalize(path) or nil
end

local function parentOf(path)
	return path:match("^(.*)/[^/]+$")
end

-- Precedence when several statuses collapse onto one directory entry:
-- a real change outranks untracked, which outranks ignored.
local function rankOf(status)
	if status == "!!" then return 0 end
	if status == "??" then return 1 end
	return 2
end

local function setStatus(map, path, status)
	local existing = map[path]
	if existing == nil or rankOf(status) > rankOf(existing) then map[path] = status end
end

-- Parse `git status --porcelain --ignored` into { [absolutePath] = "XY" }.
-- Git reports paths relative to the repo root, so absolute keys make lookups
-- independent of which directory a given window happens to show. Each status is
-- propagated to *every* ancestor directory up to the repo root, which is what
-- makes the whole chain of mini.files windows light up for one nested change.
local function parseGitStatus(content, root)
	local map = {}
	for line in content:gmatch("[^\r\n]+") do
		local status, filePath = line:match("^(..) (.*)$")
		if status and filePath then
			-- renames/copies are reported as "old -> new"; key off the destination
			filePath = filePath:match("^.* %-> (.*)$") or filePath
			filePath = filePath:gsub("/+$", "") -- directories carry a trailing slash
			if filePath ~= "" then
				local path = root .. "/" .. filePath
				setStatus(map, path, status)
				local parent = parentOf(path)
				while parent and #parent > #root do
					setStatus(map, parent, status)
					parent = parentOf(parent)
				end
			end
		end
	end
	return map
end

-- Git collapses untracked and ignored *directories* into a single entry, so
-- their contents never appear in the output. Inherit those two statuses
-- downwards; any other ancestor status means the ancestor is merely a parent of
-- some other change and says nothing about this entry.
local function statusFor(map, path, root)
	local status = map[path]
	if status then return status end
	local parent = parentOf(path)
	while parent and #parent >= #root do
		local parentStatus = map[parent]
		if parentStatus == "??" or parentStatus == "!!" then return parentStatus end
		if parentStatus then return nil end
		parent = parentOf(parent)
	end
	return nil
end

-- Apply git signs to all entries in a mini.files buffer. Lookups are keyed by
-- absolute path, so a result arriving late cannot paint the wrong directory
-- even if mini.files reused the buffer in the meantime.
local function applyGitSigns(buf_id, root, map)
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(buf_id) then return end

		local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
		vim.api.nvim_buf_clear_namespace(buf_id, nsMiniFiles, 0, -1)

		for i, line in ipairs(lines) do
			local entry = MiniFiles.get_fs_entry(buf_id, i)
			if not entry then break end

			local status = statusFor(map, normalize(entry.path), root)
			if status then
				local symbol, hlGroup = mapSymbols(status, isSymlink(entry.path))
				if symbol ~= "" then
					vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
						sign_text = symbol,
						sign_hl_group = hlGroup,
						priority = 2,
					})
				end
				-- Highlight the filename text as well
				local nameCol = line:find(entry.name, 1, true) or 0
				if nameCol > 0 then
					vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, nameCol - 1, {
						end_col = nameCol + #entry.name - 1,
						hl_group = hlGroup,
					})
				end
			end
		end
	end)
end

-- Drop cache entries nobody is going to reuse, so a long session browsing many
-- repositories does not grow the table without bound.
local function pruneCache(now)
	for root, entry in pairs(cache) do
		if now - entry.time >= CACHE_TTL then cache[root] = nil end
	end
end

-- Fetch (or reuse) the status snapshot for a repository. `--ignored=traditional`
-- collapses ignored directories so large ones (node_modules) stay cheap, and
-- `core.quotePath=false` keeps paths with spaces or non-ASCII characters
-- readable instead of escaped. Concurrent requests for the same repo — which is
-- the normal case, one per open window — share a single git invocation.
local function fetchStatus(root, callback)
	local now = os.time()
	local cached = cache[root]
	if cached and (now - cached.time < CACHE_TTL) then
		callback(cached.map)
		return
	end

	local waiters = pending[root]
	if waiters then
		waiters[#waiters + 1] = callback
		return
	end
	pending[root] = { callback }
	local startedAt = generation

	vim.system({
		"git",
		"-c",
		"core.quotePath=false",
		"status",
		"--porcelain",
		"--ignored=traditional",
	}, { text = true, cwd = root }, function(result)
		local callbacks = pending[root] or {}
		pending[root] = nil
		if result.code ~= 0 then return end
		-- An invalidation landed while git was running: this snapshot predates
		-- the change, so drop it and let the pending refresh produce a fresh one.
		if startedAt ~= generation then return end

		local map = parseGitStatus(result.stdout or "", root)
		pruneCache(os.time())
		cache[root] = { time = os.time(), map = map }
		for _, cb in ipairs(callbacks) do
			cb(map)
		end
	end)
end

local function updateGitStatus(buf_id)
	local dir = getBufDir(buf_id)
	if not dir then return end
	local root = vim.fs.root(dir, ".git")
	if not root then return end
	root = normalize(root)

	fetchStatus(root, function(map)
		applyGitSigns(buf_id, root, map)
	end)
end

-- Repaint every live mini.files buffer, not just the focused one: a single
-- change deep in the tree must light up each ancestor window as well.
local function refreshAll()
	for buf_id in pairs(trackedBufs) do
		if vim.api.nvim_buf_is_valid(buf_id) then
			updateGitStatus(buf_id)
		else
			trackedBufs[buf_id] = nil
		end
	end
end

-- Invalidation events arrive in bursts (a rename fires several, `:wall` fires
-- one per buffer); coalesce them into a single git call.
local refreshTimer = uv.new_timer()
local function invalidate()
	generation = generation + 1
	cache = {}
	pending = {}
	refreshTimer:stop()
	refreshTimer:start(50, 0, vim.schedule_wrap(refreshAll))
end

local function augroup(name)
	return vim.api.nvim_create_augroup("MiniFiles_" .. name, { clear = true })
end

-- Add buffer-local keymaps when mini.files creates a buffer
autocmd("User", {
	group = augroup("buf_keymaps"),
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		trackedBufs[args.data.buf_id] = true
		vim.keymap.set("n", "<C-c>", MiniFiles.close, { buffer = args.data.buf_id })
	end,
})

-- Load signs when the explorer opens
autocmd("User", {
	group = augroup("start"),
	pattern = "MiniFilesExplorerOpen",
	callback = refreshAll,
})

-- Load signs when navigating into a new directory (buffers are reused per path)
autocmd("User", {
	group = augroup("update"),
	pattern = "MiniFilesBufferUpdate",
	callback = function(args)
		trackedBufs[args.data.buf_id] = true
		updateGitStatus(args.data.buf_id)
	end,
})

-- Anything that can change git status invalidates the cache immediately,
-- otherwise the TTL would keep serving pre-action results.
autocmd("User", {
	group = augroup("invalidate"),
	pattern = {
		"MiniFilesActionCreate",
		"MiniFilesActionDelete",
		"MiniFilesActionRename",
		"MiniFilesActionCopy",
		"MiniFilesActionMove",
	},
	callback = invalidate,
})

autocmd("BufWritePost", {
	group = augroup("invalidate_write"),
	callback = invalidate,
})

autocmd("User", {
	group = augroup("stop"),
	pattern = "MiniFilesExplorerClose",
	callback = function()
		trackedBufs = {}
	end,
})
