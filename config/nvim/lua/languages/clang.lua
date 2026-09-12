local M = {}

local function is_windows()
	return vim.fn.has("win32") == 1
end

-- VS LLVM 20: indexer is this drop's clangd (matches UBT clang-cl).
-- Append the bin dir so format/lint resolve; do not prepend.
local vs_llvm_bin
if is_windows() then
	local dirs = vim.fn.glob(
		"C:/Program Files/Microsoft Visual Studio/*/*/VC/Tools/Llvm/x64/bin",
		false,
		true
	)
	vs_llvm_bin = dirs[1] and vim.fs.normalize(dirs[1]) or nil
end
if vs_llvm_bin then
	local path = vim.env.PATH or ""
	if not path:lower():find(vs_llvm_bin:lower(), 1, true) then
		vim.env.PATH = path .. ";" .. vs_llvm_bin
	end
end

local clangd_exe = "clangd"
if vs_llvm_bin then
	local exe = vs_llvm_bin .. "/clangd.exe"
	if vim.fn.filereadable(exe) == 1 then clangd_exe = exe end
end

local function normalize_path(path)
	return vim.fs.normalize(path):gsub("\\", "/"):lower()
end

local function ancestor_file(path, name)
	local dir = vim.fs.dirname(vim.fs.normalize(path))
	return vim.fs.find(name, {
		upward = true,
		path = dir,
		type = "file",
	})[1]
end

local function ancestor_uproject(path)
	local dir = vim.fs.dirname(vim.fs.normalize(path))
	return vim.fs.find(function(name)
		return name:lower():sub(-9) == ".uproject"
	end, { upward = true, path = dir, type = "file" })[1]
end

-- Non-Unreal trees: run if the Style file / Check set exists.
-- Unreal: project Source/ only, or a Plugins/ tree that owns the config.
-- Never Engine, Intermediate, Saved, ThirdParty. Vendor plugin Source/
-- is still Plugins/, so a project-root Style file does not opt it in.
function M.should_run_cpp_tool(path, config_name)
	if not path or path == "" then return false end
	local normalized = normalize_path(path)
	if
		normalized:find("/intermediate/", 1, true)
		or normalized:find("/saved/", 1, true)
		or normalized:find("/thirdparty/", 1, true)
		or normalized:find("/third_party/", 1, true)
		or normalized:find("/engine/source/", 1, true)
	then
		return false
	end

	local config = ancestor_file(path, config_name)
	if not config then return false end

	local uproject = ancestor_uproject(path)
	if not uproject then return true end

	local project_root = normalize_path(vim.fs.dirname(uproject))
	local prefix = project_root .. "/"
	if not vim.startswith(normalized, prefix) then return false end
	local rel = normalized:sub(#prefix + 1)

	local plugin = rel:match("^plugins/([^/]+)/")
	if plugin then
		return vim.startswith(normalize_path(config), prefix .. "plugins/" .. plugin .. "/")
	end

	return vim.startswith(rel, "source/")
end

local clangd_cmd = {
	clangd_exe,
	"--background-index",
	"--completion-style=detailed",
	"--function-arg-placeholders",
	"--fallback-style=llvm",
}

if is_windows() then
	clangd_cmd[#clangd_cmd + 1] = "--query-driver="
		.. "C:/Program Files/Microsoft Visual Studio/**/clang-cl.exe"
end

M.lsp = {
	servers = {
		clangd = {
			capabilities = {
				offsetEncoding = { "utf-16" },
			},
			cmd = clangd_cmd,
			init_options = {
				usePlaceholders = true,
				completeUnimported = true,
				clangdFileStatus = true,
			},
		},
	},
	setup = {
		clangd = function()
			require("clangd_extensions").setup({
				inlay_hints = {
					inline = false,
				},
				ast = {
					role_icons = {
						type = "",
						declaration = "",
						expression = "",
						specifier = "",
						statement = "",
						["template argument"] = "",
					},
					kind_icons = {
						Compound = "",
						Recovery = "",
						TranslationUnit = "",
						PackExpansion = "",
						TemplateTypeParm = "",
						TemplateTemplateParm = "",
						TemplateParamObject = "",
					},
				},
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "c", "cpp" },
				callback = function(args)
					vim.keymap.set(
						"n",
						"<F10>",
						"<cmd>ClangdSwitchSourceHeader<cr>",
						{ buffer = args.buf }
					)
				end,
			})
		end,
	},
}

M.format = {
	formatters_by_ft = {
		c = { "clang_format" },
		cpp = { "clang_format" },
	},
	formatters = {
		clang_format = {
			condition = function(_, ctx)
				return M.should_run_cpp_tool(ctx.filename, ".clang-format")
			end,
		},
	},
}

M.lint = {
	linters_by_ft = {
		c = { "clangtidy" },
		cpp = { "clangtidy" },
	},
	linters = {
		clangtidy = {
			condition = function(ctx)
				return M.should_run_cpp_tool(ctx.filename, ".clang-tidy")
			end,
		},
	},
}

return M
