local npairs_ok, npairs = pcall(require, "nvim-autopairs")

if not npairs_ok then
	return
end

local Rule = require("nvim-autopairs.rule")
local conds = require("nvim-autopairs.conds")

npairs.setup()

-- Autoclosing angle-brackets.
npairs.add_rule(Rule("<", ">", {
	-- Avoid conflicts with nvim-ts-autotag.
	"-html",
	"-javascriptreact",
	"-typescriptreact",
}):with_pair(conds.before_regex("%a+:?:?$", 3)):with_move(function(opts)
	return opts.char == ">"
end))

local autotag_ok, autotag = pcall(require, "nvim-ts-autotag")

if autotag_ok then
	autotag.setup()
end
