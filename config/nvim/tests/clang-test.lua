-- Headless check of the C++ Language config seam.
-- nvim --headless -u NONE -l config/nvim/tests/clang-test.lua

local this = debug.getinfo(1, "S").source:sub(2)
local lua = vim.fn.fnamemodify(this, ":p:h:h") .. "/lua/?.lua;"
package.path = lua .. package.path

local failures, passes = {}, 0

local function assert_eq(name, got, expected)
	if got == expected then
		passes = passes + 1
		return
	end
	failures[#failures + 1] = name
		.. ": got "
		.. vim.inspect(got)
		.. ", expected "
		.. vim.inspect(expected)
end

local function write_file(path)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
	vim.fn.writefile({ "" }, path)
end

local function join(...)
	return vim.fs.joinpath(...)
end

local orig_path = vim.env.PATH
local clang = require("languages.clang")
if type(clang.should_run_cpp_tool) ~= "function" then
	print("FAILED: should_run_cpp_tool is not a function")
	os.exit(1)
end

local unreal = vim.fn.tempname()
local engine = vim.fn.tempname()
local other = vim.fn.tempname()
local bare = vim.fn.tempname()
local source_host = vim.fn.tempname()
local plugins_host = vim.fn.tempname()
local under_source = join(source_host, "source", "Game")
local under_plugins = join(plugins_host, "plugins", "UE", "Game")
local fmt, tidy = ".clang-format", ".clang-tidy"
local policy = clang.should_run_cpp_tool

local source = join(unreal, "Source", "Game", "Foo.cpp")
local vendor = join(unreal, "Plugins", "Vendor", "Source", "V.cpp")
local owned = join(unreal, "Plugins", "FirstParty", "Source", "P.cpp")
local actor = join(engine, "Engine", "Source", "Runtime", "A.cpp")
local inter = join(unreal, "Intermediate", "Build", "Foo.cpp")
local saved = join(unreal, "Saved", "Foo.cpp")
local third = join(unreal, "ThirdParty", "Lib", "Foo.cpp")
local src_tp = join(unreal, "Source", "ThirdParty", "Lib", "Foo.cpp")
local src_tpu = join(unreal, "Source", "third_party", "Lib", "Foo.cpp")
local qt = join(other, "src", "main.cpp")
local none = join(bare, "src", "main.cpp")
local src_root = join(under_source, "Foo.cpp")
local src_ok = join(under_source, "Source", "Foo.cpp")
local plug_docs = join(under_plugins, "Docs", "Foo.cpp")
local plug_ok = join(under_plugins, "Source", "Foo.cpp")

for _, path in ipairs({
	join(unreal, "Game.uproject"),
	join(unreal, fmt),
	join(unreal, tidy),
	source,
	vendor,
	join(unreal, "Plugins", "FirstParty", fmt),
	join(unreal, "Plugins", "FirstParty", tidy),
	owned,
	inter,
	saved,
	third,
	src_tp,
	src_tpu,
	join(engine, fmt),
	join(engine, tidy),
	actor,
	join(other, fmt),
	join(other, tidy),
	qt,
	none,
	join(under_source, "Game.uproject"),
	join(under_source, fmt),
	src_root,
	src_ok,
	join(under_plugins, "Game.uproject"),
	join(under_plugins, fmt),
	plug_docs,
	plug_ok,
}) do
	write_file(path)
end

local cases = {
	{ "Source/ style", source, fmt, true },
	{ "Source/ tidy", source, tidy, true },
	{ "vendor plugin style", vendor, fmt, false },
	{ "vendor plugin tidy", vendor, tidy, false },
	{ "owned plugin style", owned, fmt, true },
	{ "owned plugin tidy", owned, tidy, true },
	{ "Engine/Source", actor, fmt, false },
	{ "Intermediate/", inter, fmt, false },
	{ "Saved/", saved, fmt, false },
	{ "ThirdParty/", third, fmt, false },
	{ "Source/ThirdParty/", src_tp, fmt, false },
	{ "third_party/", src_tpu, fmt, false },
	{ "non-Unreal style", qt, fmt, true },
	{ "non-Unreal tidy", qt, tidy, true },
	{ "missing style", none, fmt, false },
	{ "missing tidy", none, tidy, false },
	{ "empty path", "", fmt, false },
	{ "ancestor source/ root file", src_root, fmt, false },
	{ "ancestor source/ Source/", src_ok, fmt, true },
	{ "ancestor plugins/ docs", plug_docs, fmt, false },
	{ "ancestor plugins/ Source/", plug_ok, fmt, true },
}
for _, c in ipairs(cases) do
	assert_eq(c[1], policy(c[2], c[3]), c[4])
end

local fmt_ok = clang.format.formatters.clang_format.condition
local lint_ok = clang.lint.linters.clangtidy.condition
assert_eq("format uses policy", fmt_ok(nil, { filename = source }), true)
assert_eq("format denies vendor", fmt_ok(nil, { filename = vendor }), false)
assert_eq("lint uses policy", lint_ok({ filename = source }), true)
assert_eq("lint denies vendor", lint_ok({ filename = vendor }), false)
assert_eq("c format name", clang.format.formatters_by_ft.c[1], "clang_format")
assert_eq(
	"cpp format name",
	clang.format.formatters_by_ft.cpp[1],
	"clang_format"
)
assert_eq("c lint name", clang.lint.linters_by_ft.c[1], "clangtidy")
assert_eq("cpp lint name", clang.lint.linters_by_ft.cpp[1], "clangtidy")

local cmd = table.concat(clang.lsp.servers.clangd.cmd, "\0")
local exe = clang.lsp.servers.clangd.cmd[1]
assert_eq(
	"cmd is clangd",
	exe == "clangd" or exe:find("clangd%.exe$") ~= nil,
	true
)
assert_eq("no --clang-tidy", cmd:find("--clang-tidy", 1, true) ~= nil, false)
assert_eq("no iwyu", cmd:find("iwyu", 1, true) ~= nil, false)
assert_eq("setup remains", type(clang.lsp.setup.clangd), "function")

local function load_clang_with_win32(value)
	local orig = vim.fn.has
	vim.fn.has = function(feat)
		return feat == "win32" and value or orig(feat)
	end
	package.loaded["languages.clang"] = nil
	local ok, loaded = pcall(require, "languages.clang")
	vim.fn.has = orig
	package.loaded["languages.clang"] = nil
	assert(ok, loaded)
	return loaded
end

local win_cmd = load_clang_with_win32(1).lsp.servers.clangd.cmd
local nix_cmd = load_clang_with_win32(0).lsp.servers.clangd.cmd
local win = table.concat(win_cmd, "\0")
assert_eq("win query-driver", win:find("--query-driver=", 1, true) ~= nil, true)
assert_eq("win clang-cl", win:find("clang-cl.exe", 1, true) ~= nil, true)
assert_eq(
	"Native Windows clangd is VS LLVM",
	win_cmd[1]:find("clangd.exe", 1, true) ~= nil
		and win_cmd[1]:lower():find("llvm", 1, true) ~= nil,
	true
)
assert_eq(
	"nix no query-driver",
	table.concat(nix_cmd, "\0"):find("--query-driver=", 1, true) ~= nil,
	false
)
assert_eq("non-Windows clangd is PATH clangd", nix_cmd[1], "clangd")

vim.env.PATH = orig_path
for _, dir in ipairs({ unreal, engine, other, bare, source_host, plugins_host }) do
	vim.fn.delete(dir, "rf")
end

if #failures > 0 then
	print(string.format("FAILED %d, passed %d", #failures, passes))
	print(table.concat(failures, "\n"))
	os.exit(1)
end
print(string.format("ok %d", passes))
os.exit(0)
