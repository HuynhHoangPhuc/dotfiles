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
	if not MiniFiles.close() then
		MiniFiles.open(vim.api.nvim_buf_get_name(0), true)
	end
end)
vim.keymap.set("n", "<leader>E", function()
	MiniFiles.open(vim.uv.cwd(), true)
end)

local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")
local autocmd = vim.api.nvim_create_autocmd
local uv = vim.uv or vim.loop

-- [dir] = { time, map }. Never cleared on close so reopening is instant;
-- expiry is by TTL, plus explicit invalidation after file actions/writes.
local cache = {}
local CACHE_TTL = 10 -- seconds

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
	if not is_symlink then
		return entry.symbol, entry.hlGroup
	end
	-- `sign_text` is capped at 2 display cells, so the symlink marker only
	-- prefixes symbols that leave room for it.
	local symbol = vim.fn.strdisplaywidth(entry.symbol) >= 2 and "↩" or ("↩" .. entry.symbol)
	return symbol, "MiniDiffSignDelete"
end

-- Get the directory currently displayed in a mini.files buffer
local function getCurrentDir(buf_id)
	local entry = MiniFiles.get_fs_entry(buf_id, 1)
	if not entry then return nil end
	return vim.fn.fnamemodify(entry.path, ":h")
end

-- Precedence when several statuses collapse onto one directory entry:
-- a real change outranks untracked, which outranks ignored.
local function rankOf(status)
	if status == "!!" then return 0 end
	if status == "??" then return 1 end
	return 2
end

-- Parse `git status --porcelain --ignored` into { [name] = "XY" }.
-- prefix: path of the displayed dir relative to git root (e.g. "src/components"),
--         "" when viewing the repo root. Needed because git always reports paths
--         relative to the repo root.
-- Statuses propagate up to parent directory entries so nested changes are visible.
local function parseGitStatus(content, prefix)
	local map = {}
	local stripPrefix = prefix ~= "" and (prefix .. "/") or ""
	for line in content:gmatch("[^\r\n]+") do
		local status, filePath = line:match("^(..) (.*)$")
		if status and filePath then
			-- renames/copies are reported as "old -> new"; key off the destination
			filePath = filePath:match("^.* %-> (.*)$") or filePath
			filePath = filePath:gsub("/$", "") -- directories carry a trailing slash
			if stripPrefix ~= "" then
				filePath = filePath:match("^" .. vim.pesc(stripPrefix) .. "(.+)")
			end
			if filePath and filePath ~= "" then
				local key = ""
				for part in filePath:gmatch("[^/]+") do
					key = key == "" and part or (key .. "/" .. part)
					local existing = map[key]
					if existing == nil or rankOf(status) > rankOf(existing) then
						map[key] = status
					end
				end
			end
		end
	end
	return map
end

-- Apply git signs to all entries in a mini.files buffer.
-- `dir` guards against a stale async result landing on a buffer that mini.files
-- has since reused for a different directory.
local function applyGitSigns(buf_id, dir, map)
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(buf_id) then return end
		if getCurrentDir(buf_id) ~= dir then return end

		local nlines = vim.api.nvim_buf_line_count(buf_id)
		vim.api.nvim_buf_clear_namespace(buf_id, nsMiniFiles, 0, -1)

		for i = 1, nlines do
			local entry = MiniFiles.get_fs_entry(buf_id, i)
			if not entry then break end

			local status = map[entry.name]
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
				local line = vim.api.nvim_buf_get_lines(buf_id, i - 1, i, false)[1]
				local nameCol = line and line:find(entry.name, 1, true) or 0
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
-- directories does not grow the table without bound.
local function pruneCache(now)
	for dir, entry in pairs(cache) do
		if now - entry.time >= CACHE_TTL then cache[dir] = nil end
	end
end

-- Load git status for the directory shown in buf_id. A single `git status` call
-- covers changes and ignored entries; `--ignored=traditional` collapses ignored
-- directories so large ones (node_modules) stay cheap. `core.quotePath=false`
-- keeps paths with spaces or non-ASCII characters readable instead of escaped.
local function updateGitStatus(buf_id)
	local dir = getCurrentDir(buf_id)
	if not dir then return end
	local gitRoot = vim.fs.root(dir, ".git")
	if not gitRoot then return end

	local now = os.time()
	local cached = cache[dir]
	if cached and (now - cached.time < CACHE_TTL) then
		applyGitSigns(buf_id, dir, cached.map)
		return
	end
	pruneCache(now)

	local prefix = dir:sub(#gitRoot + 2)
	vim.system({
		"git",
		"-c",
		"core.quotePath=false",
		"status",
		"--porcelain",
		"--ignored=traditional",
		".",
	}, { text = true, cwd = dir }, function(result)
		if result.code ~= 0 then return end
		local map = parseGitStatus(result.stdout, prefix)
		cache[dir] = { time = os.time(), map = map }
		applyGitSigns(buf_id, dir, map)
	end)
end

local function augroup(name)
	return vim.api.nvim_create_augroup("MiniFiles_" .. name, { clear = true })
end

-- Add buffer-local keymaps when mini.files creates a buffer
autocmd("User", {
	group = augroup("buf_keymaps"),
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		vim.keymap.set("n", "<C-c>", MiniFiles.close, { buffer = args.data.buf_id })
	end,
})

-- Load signs when the explorer opens
autocmd("User", {
	group = augroup("start"),
	pattern = "MiniFilesExplorerOpen",
	callback = function()
		updateGitStatus(vim.api.nvim_get_current_buf())
	end,
})

-- Load signs when navigating into a new directory (buffers are reused per path)
autocmd("User", {
	group = augroup("update"),
	pattern = "MiniFilesBufferUpdate",
	callback = function(args)
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
	callback = function()
		cache = {}
	end,
})

autocmd("BufWritePost", {
	group = augroup("invalidate_write"),
	callback = function()
		cache = {}
	end,
})
