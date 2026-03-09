local _, MiniFiles = pcall(require, "mini.files")
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

-- Separate caches with different TTLs:
-- git status changes frequently, ignored files rarely change
local cache = {
	status  = {},  -- [dir] = { time, map }   TTL: 10s
	ignored = {},  -- [dir] = { time, map }   TTL: 60s
}
local STATUS_TTL  = 10   -- seconds
local IGNORED_TTL = 60   -- seconds

local function isSymlink(path)
	local stat = uv.fs_lstat(path)
	return stat and stat.type == "link"
end

---@type table<string, {symbol: string, hlGroup: string}>
local symbolMap = {
	-- stylua: ignore start
	[" M"] = { symbol = "•",  hlGroup = "MiniDiffSignChange" }, -- modified in working dir
	["M "] = { symbol = "✹",  hlGroup = "MiniDiffSignChange" }, -- modified in index
	["MM"] = { symbol = "≠",  hlGroup = "MiniDiffSignChange" }, -- modified in both
	["A "] = { symbol = "+",  hlGroup = "MiniDiffSignAdd"    }, -- added to staging
	["AA"] = { symbol = "≈",  hlGroup = "MiniDiffSignAdd"    }, -- added in both
	["D "] = { symbol = "-",  hlGroup = "MiniDiffSignDelete" }, -- deleted from staging
	["AM"] = { symbol = "⊕",  hlGroup = "MiniDiffSignChange" }, -- added in worktree, modified in index
	["AD"] = { symbol = "-•", hlGroup = "MiniDiffSignChange" }, -- added in index, deleted in worktree
	["R "] = { symbol = "→",  hlGroup = "MiniDiffSignChange" }, -- renamed in index
	["U "] = { symbol = "‖",  hlGroup = "MiniDiffSignChange" }, -- unmerged path
	["UU"] = { symbol = "⇄",  hlGroup = "MiniDiffSignAdd"    }, -- both modified (unmerged)
	["UA"] = { symbol = "⊕",  hlGroup = "MiniDiffSignAdd"    }, -- added by them (unmerged)
	["??"] = { symbol = "?",  hlGroup = "MiniDiffSignDelete" }, -- untracked
	["!!"] = { symbol = "",   hlGroup = "Comment"            }, -- ignored (no sign, dimmed color)
	-- stylua: ignore end
}

local function mapSymbols(status, is_symlink)
	local result = symbolMap[status] or { symbol = "?", hlGroup = "NonText" }
	local symlinkSymbol = is_symlink and "↩" or ""
	local combined = (symlinkSymbol .. result.symbol):gsub("^%s+", ""):gsub("%s+$", "")
	local hlGroup = is_symlink and "MiniDiffSignDelete" or result.hlGroup
	return combined, hlGroup
end

-- Get the directory currently displayed in a mini.files buffer
local function getCurrentDir(buf_id)
	local entry = MiniFiles.get_fs_entry(buf_id, 1)
	if not entry then return nil end
	return vim.fn.fnamemodify(entry.path, ":h")
end

-- Parse `git status --porcelain .` into { [name] = "XY" }
-- Propagates status up to parent directory entries for nested paths
local function parseGitStatus(content)
	local map = {}
	for line in content:gmatch("[^\r\n]+") do
		local status, filePath = line:match("^(..)%s+(.*)")
		if status and filePath then
			local parts = {}
			for part in filePath:gmatch("[^/]+") do
				table.insert(parts, part)
			end
			local key = ""
			for i, part in ipairs(parts) do
				key = i == 1 and part or (key .. "/" .. part)
				if i == #parts then
					map[key] = status
				elseif not map[key] then
					-- propagate to parent dir so it shows a sign too
					map[key] = status
				end
			end
		end
	end
	return map
end

-- Parse `git ls-files --ignored` into { [name] = "!!" }
local function parseIgnoredFiles(content)
	local map = {}
	for line in content:gmatch("[^\r\n]+") do
		local name = line:gsub("/$", "")  -- strip trailing slash from dirs
		if name ~= "" then
			map[name] = "!!"
		end
	end
	return map
end

-- Apply git signs to all entries in a mini.files buffer
local function applyGitSigns(buf_id, combinedMap)
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(buf_id) then return end
		local nlines = vim.api.nvim_buf_line_count(buf_id)
		vim.api.nvim_buf_clear_namespace(buf_id, nsMiniFiles, 0, -1)

		for i = 1, nlines do
			local entry = MiniFiles.get_fs_entry(buf_id, i)
			if not entry then break end

			local status = combinedMap[entry.name]
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
				local nameCol = line:find(vim.pesc(entry.name)) or 0
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

-- Load git status for the directory shown in buf_id.
-- Two async queries run independently:
--   1. git status --porcelain .      (fast, ~50-100ms) — shown first
--   2. git ls-files --ignored ...    (dedicated cmd, ~100-300ms) — merged after
-- Results are cached separately; ignored files use a longer TTL.
local function updateGitStatus(buf_id)
	local dir = getCurrentDir(buf_id)
	if not dir or not vim.fs.root(dir, ".git") then return end

	-- Merge both caches and redraw signs
	local function redraw()
		local sMap = cache.status[dir]  and cache.status[dir].map  or {}
		local iMap = cache.ignored[dir] and cache.ignored[dir].map or {}
		-- status entries take priority over ignored markers on conflict
		applyGitSigns(buf_id, vim.tbl_extend("keep", sMap, iMap))
	end

	local now = os.time()

	-- Query 1: fast status (modified/added/deleted/untracked)
	if cache.status[dir] and (now - cache.status[dir].time < STATUS_TTL) then
		redraw()
	else
		vim.system(
			{ "git", "status", "--porcelain", "." },
			{ text = true, cwd = dir },
			function(result)
				if result.code == 0 then
					cache.status[dir] = { time = os.time(), map = parseGitStatus(result.stdout) }
					redraw()
				end
			end
		)
	end

	-- Query 2: ignored files (runs in parallel, merges when done)
	if not (cache.ignored[dir] and (now - cache.ignored[dir].time < IGNORED_TTL)) then
		vim.system(
			{ "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory", "." },
			{ text = true, cwd = dir },
			function(result)
				if result.code == 0 then
					cache.ignored[dir] = { time = os.time(), map = parseIgnoredFiles(result.stdout) }
					redraw()
				end
			end
		)
	end
end

local function augroup(name)
	return vim.api.nvim_create_augroup("MiniFiles_" .. name, { clear = true })
end

-- Load signs when explorer opens
autocmd("User", {
	group = augroup("start"),
	pattern = "MiniFilesExplorerOpen",
	callback = function()
		updateGitStatus(vim.api.nvim_get_current_buf())
	end,
})

-- Load signs when navigating into a new directory (new buffer created per dir)
autocmd("User", {
	group = augroup("update"),
	pattern = "MiniFilesBufferUpdate",
	callback = function(args)
		updateGitStatus(args.data.buf_id)
	end,
})

-- Cache is intentionally NOT cleared on close — TTL handles expiry.
-- This makes reopening the explorer near-instant on repeat opens.
