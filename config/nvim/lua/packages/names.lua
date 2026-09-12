-- Maps tool names used in lua/languages/* to the mason package that provides them.
-- Keys are nvim-lspconfig server names, conform.nvim formatter names and nvim-lint
-- linter names; values are mason-registry package names.
-- A commented-out key means the tool exists in the plugin but mason has no package
-- for it (it comes from a toolchain, or was dropped from the registry).
return {
	-- nvim-lspconfig servers (mason package names from the registry)
	air = "air",
	angularls = "angular-language-server",
	ansiblels = "ansible-language-server",
	antlersls = "antlers-language-server",
	arduino_language_server = "arduino-language-server",
	asm_lsp = "asm-lsp",
	ast_grep = "ast-grep",
	astro = "astro-language-server",
	autohotkey_lsp = "autohotkey_lsp",
	autotools_ls = "autotools-language-server",
	awk_ls = "awk-language-server",
	azure_pipelines_ls = "azure-pipelines-language-server",
	bacon_ls = "bacon-ls",
	basedpyright = "basedpyright",
	bashls = "bash-language-server",
	basics_ls = "basics-language-server",
	bazelrc_lsp = "bazelrc-lsp",
	beancount = "beancount-language-server",
	bicep = "bicep-lsp",
	biome = "biome",
	bqls = "bqls",
	bright_script = "brighterscript",
	bsl_ls = "bsl-language-server",
	buf_ls = "buf",
	c3_lsp = "c3-lsp",
	cairo_ls = "cairo-language-server",
	cds_lsp = "cds-lsp",
	clangd = "clangd",
	clojure_lsp = "clojure-lsp",
	cmake = "cmake-language-server",
	cobol_ls = "cobol-language-support",
	codebook = "codebook",
	copilot = "copilot-language-server",
	coq_lsp = "coq-lsp",
	cqlls = "cqlls",
	crystalline = "crystalline",
	csharp_ls = "csharp-language-server",
	cspell_ls = "cspell-lsp",
	css_variables = "css-variables-language-server",
	csskit = "csskit",
	cssls = "css-lsp",
	cssmodules_ls = "cssmodules-language-server",
	ctags_lsp = "ctags-lsp",
	cucumber_language_server = "cucumber-language-server",
	cue = "cue",
	custom_elements_ls = "custom-elements-languageserver",
	cypher_ls = "cypher-language-server",
	dagger = "cuelsp",
	denols = "deno",
	dexter = "dexter",
	dhall_lsp_server = "dhall-lsp",
	diagnosticls = "diagnostic-languageserver",
	djls = "django-language-server",
	djlsp = "django-template-lsp",
	docker_compose_language_service = "docker-compose-language-service",
	docker_language_server = "docker-language-server",
	dockerls = "dockerfile-language-server",
	dotls = "dot-language-server",
	dprint = "dprint",
	earthlyls = "earthlyls",
	efm = "efm",
	elixirls = "elixir-ls",
	elmls = "elm-language-server",
	elp = "elp",
	ember = "ember-language-server",
	emmet_language_server = "emmet-language-server",
	emmet_ls = "emmet-ls",
	emmylua_ls = "emmylua_ls",
	erg_language_server = "erg-language-server",
	esbonio = "esbonio",
	eslint = "eslint-lsp",
	expert = "expert",
	facility_language_server = "facility-language-server",
	fennel_language_server = "fennel-language-server",
	fennel_ls = "fennel-ls",
	fish_lsp = "fish-lsp",
	flux_lsp = "flux-lsp",
	foam_ls = "foam-language-server",
	fortitude = "fortitude",
	fortls = "fortls",
	fsautocomplete = "fsautocomplete",
	gh_actions_ls = "gh-actions-language-server",
	ginko_ls = "ginko_ls",
	gitlab_ci_ls = "gitlab-ci-ls",
	glint = "glint",
	glsl_analyzer = "glsl_analyzer",
	glslls = "glslls",
	gn_language_server = "gn-language-server",
	golangci_lint_ls = "golangci-lint-langserver",
	gopls = "gopls",
	gradle_ls = "gradle-language-server",
	graphql = "graphql-language-service-cli",
	groovyls = "groovy-language-server",
	harper_ls = "harper-ls",
	hdl_checker = "hdl-checker",
	helm_ls = "helm-ls",
	herb_ls = "herb-language-server",
	hls = "haskell-language-server",
	home_assistant = "vscode-home-assistant",
	hoon_ls = "hoon-language-server",
	html = "html-lsp",
	htmx = "htmx-lsp",
	hydra_lsp = "hydra-lsp",
	hylo_ls = "hylo-language-server",
	hyprls = "hyprls",
	intelephense = "intelephense",
	java_language_server = "java-language-server",
	jdtls = "jdtls",
	jedi_language_server = "jedi-language-server",
	jinja_lsp = "jinja-lsp",
	jqls = "jq-lsp",
	jsonls = "json-lsp",
	jsonnet_ls = "jsonnet-language-server",
	julials = "julia-lsp",
	just = "just-lsp",
	kakehashi = "kakehashi",
	kcl = "kcl",
	kotlin_language_server = "kotlin-language-server",
	kotlin_lsp = "kotlin-lsp",
	laravel_ls = "laravel-ls",
	lelwel_ls = "lelwel",
	lemminx = "lemminx",
	lexical = "lexical",
	ltex = "ltex-ls",
	ltex_plus = "ltex-ls-plus",
	lua_ls = "lua-language-server",
	luau_lsp = "luau-lsp",
	lwc_ls = "lwc-language-server",
	markdown_oxide = "markdown-oxide",
	["marko-js"] = "marko-language-server",
	marksman = "marksman",
	matlab_ls = "matlab-language-server",
	mdx_analyzer = "mdx-analyzer",
	mesonlsp = "mesonlsp",
	millet = "millet",
	mm0_ls = "metamath-zero-lsp",
	motoko_lsp = "motoko-lsp",
	move_analyzer = "move-analyzer",
	mpls = "mpls",
	mutt_ls = "mutt-language-server",
	neocmake = "neocmakelsp",
	nextflow_ls = "nextflow-language-server",
	nextls = "nextls",
	nginx_language_server = "nginx-language-server",
	nickel_ls = "nickel-lang-lsp",
	nil_ls = "nil",
	nim_langserver = "nimlangserver",
	nimls = "nimlsp",
	ocamllsp = "ocaml-lsp",
	ols = "ols",
	omnisharp = "omnisharp",
	opencl_ls = "opencl-language-server",
	openscad_lsp = "openscad-lsp",
	oxfmt = "oxfmt",
	oxlint = "oxlint",
	panache = "panache",
	pbls = "pbls",
	perlnavigator = "perlnavigator",
	pest_ls = "pest-language-server",
	phpactor = "phpactor",
	phpantom_lsp = "phpantom_lsp",
	pico8_ls = "pico8-ls",
	postgres_lsp = "postgres-language-server",
	powershell_es = "powershell-editor-services",
	prismals = "prisma-language-server",
	prosemd_lsp = "prosemd-lsp",
	protols = "protols",
	psalm = "psalm",
	puppet = "puppet-editor-services",
	purescriptls = "purescript-language-server",
	pylsp = "python-lsp-server",
	pylyzer = "pylyzer",
	pyre = "pyre",
	pyrefly = "pyrefly",
	pyright = "pyright",
	pytest_language_server = "pytest-language-server",
	qmlls = "qmlls",
	quick_lint_js = "quick-lint-js",
	r_language_server = "r-languageserver",
	raku_navigator = "raku-navigator",
	reason_ls = "reason-language-server",
	regal = "regal",
	regols = "regols",
	remark_ls = "remark-language-server",
	rescriptls = "rescript-language-server",
	rnix = "rnix-lsp",
	robotcode = "robotcode",
	robotframework_ls = "robotframework-lsp",
	roc_ls = "roc_language_server",
	roslyn_ls = "roslyn-language-server",
	rpmspec = "rpm_lsp_server",
	rubocop = "rubocop",
	ruby_lsp = "ruby-lsp",
	ruff = "ruff",
	rumdl = "rumdl",
	rust_analyzer = "rust-analyzer",
	salt_ls = "salt-lsp",
	serve_d = "serve-d",
	shopify_theme_ls = "shopify-cli",
	shuck = "shuck",
	slang_server = "slang-server",
	slangd = "slang",
	slint_lsp = "slint-lsp",
	smithy_ls = "smithy-language-server",
	snakeskin_ls = "snakeskin-cli",
	snyk_ls = "snyk-ls",
	solang = "solang",
	solargraph = "solargraph",
	solc = "solidity",
	solidity = "solidity-ls",
	solidity_ls = "vscode-solidity-server",
	solidity_ls_nomicfoundation = "nomicfoundation-solidity-language-server",
	somesass_ls = "some-sass-language-server",
	sorbet = "sorbet",
	spectral = "spectral-language-server",
	spyglassmc_language_server = "spyglassmc-language-server",
	sqlls = "sqlls",
	sqls = "sqls",
	sqruff = "sqruff",
	stan_ls = "stan-language-server",
	standardrb = "standardrb",
	starlark_rust = "starlark-rust",
	starpls = "starpls",
	statix = "statix",
	steep = "steep",
	stimulus_ls = "stimulus-language-server",
	stylelint_lsp = "stylelint-language-server",
	stylua = "stylua",
	superhtml = "superhtml",
	svelte = "svelte-language-server",
	svlangserver = "svlangserver",
	svls = "svls",
	systemd_lsp = "systemd-lsp",
	tailwindcss = "tailwindcss-language-server",
	taplo = "taplo",
	tclsp = "tclint",
	teal_ls = "teal-language-server",
	templ = "templ",
	termux_language_server = "termux-language-server",
	terraformls = "terraform-ls",
	terragrunt_ls = "terragrunt-ls",
	texlab = "texlab",
	textlsp = "textlsp",
	tflint = "tflint",
	thriftls = "thriftls",
	tinymist = "tinymist",
	tofu_ls = "tofu-ls",
	tombi = "tombi",
	ts_ls = "typescript-language-server",
	ts_query_ls = "ts_query_ls",
	tsp_server = "tsp-server",
	twiggy_language_server = "twiggy-language-server",
	ty = "ty",
	typos_lsp = "typos-lsp",
	unocss = "unocss-language-server",
	v_analyzer = "v-analyzer",
	vacuum = "vacuum",
	vala_ls = "vala-language-server",
	vale_ls = "vale-ls",
	vectorcode_server = "vectorcode",
	verible = "verible",
	veryl_ls = "veryl-ls",
	vespa_ls = "vespa-language-server",
	vhdl_ls = "rust_hdl",
	vimls = "vim-language-server",
	visualforce_ls = "visualforce-language-server",
	vls = "vls",
	vtsls = "vtsls",
	vue_ls = "vue-language-server",
	wasm_language_tools = "wasm-language-tools",
	wgsl_analyzer = "wgsl-analyzer",
	yamlls = "yaml-language-server",
	zizmor = "zizmor",
	zk = "zk",
	zls = "zls",
	zuban = "zuban",

	-- conform.nvim formatters
	alejandra = "alejandra",
	["ansible-lint"] = "ansible-lint",
	asmfmt = "asmfmt",
	["ast-grep"] = "ast-grep",
	-- astyle
	-- auto_optional
	-- autocorrect
	autoflake = "autoflake",
	autopep8 = "autopep8",
	-- awk
	bake = "mbake",
	-- bean-format
	beautysh = "beautysh",
	["bibtex-tidy"] = "bibtex-tidy",
	["biome-check"] = "biome",
	["biome-organize-imports"] = "biome",
	black = "black",
	["blade-formatter"] = "blade-formatter",
	blue = "blue",
	-- bpfmt
	bsfmt = "brighterscript-formatter",
	buf = "buf",
	buildifier = "buildifier",
	-- cabal_fmt
	-- caramel_fmt
	cbfmt = "cbfmt",
	-- cedar
	["clang-format"] = "clang-format",
	clang_format = "clang-format",
	cljfmt = "cljfmt",
	-- cljstyle
	cmake_format = "cmakelang",
	codeql = "codeql",
	codespell = "codespell",
	-- commitmsgfmt
	crlfmt = "crlfmt",
	-- crystal
	csharpier = "csharpier",
	-- css_beautify
	cue_fmt = "cue",
	-- d2
	darker = "darker",
	-- dart_format
	dcm_fix = "dcm",
	dcm_format = "dcm",
	deno_fmt = "deno",
	-- dfmt
	-- dioxus
	djlint = "djlint",
	docformatter = "docformatter",
	dockerfmt = "dockerfmt",
	-- docstrfmt
	doctoc = "doctoc",
	["easy-coding-standard"] = "easy-coding-standard",
	-- efmt
	elm_format = "elm-format",
	erb_format = "erb-formatter",
	-- erlfmt
	eslint_d = "eslint_d",
	fantomas = "fantomas",
	findent = "findent",
	-- fish_indent
	fixjson = "fixjson",
	-- fnlfmt
	-- forge_fmt
	-- format-dune-file
	fourmolu = "fourmolu",
	fprettify = "fprettify",
	-- gawk
	gci = "gci",
	gdformat = "gdtoolkit",
	["gdscript-formatter"] = "gdscript-formatter",
	gersemi = "gersemi",
	-- ghdl
	-- ghokin
	-- gleam
	-- gluon_fmt
	-- gn
	-- gofmt
	gofumpt = "gofumpt",
	goimports = "goimports",
	["goimports-reviser"] = "goimports-reviser",
	-- gojq
	["golangci-lint"] = "golangci-lint",
	golines = "golines",
	["google-java-format"] = "google-java-format",
	-- grain_format
	hcl = "hclfmt",
	-- hindent
	-- hledger-fmt
	-- html_beautify
	htmlbeautifier = "htmlbeautifier",
	-- hurlfmt
	-- imba_fmt
	-- indent
	-- inko
	isort = "isort",
	-- janet-format
	joker = "joker",
	jq = "jq",
	-- js_beautify
	json_repair = "json-repair",
	jsonnetfmt = "jsonnetfmt",
	-- just
	kdlfmt = "kdlfmt",
	-- keep-sorted
	ktfmt = "ktfmt",
	ktlint = "ktlint",
	["kulala-fmt"] = "kulala-fmt",
	latexindent = "latexindent",
	-- leptosfmt
	-- liquidsoap-prettier
	-- llf
	["lua-format"] = "luaformatter",
	-- mago_format
	-- mago_lint
	["markdown-toc"] = "markdown-toc",
	-- markdownfmt
	markdownlint = "markdownlint",
	["markdownlint-cli2"] = "markdownlint-cli2",
	mdformat = "mdformat",
	mdsf = "mdsf",
	mdslw = "mdslw",
	-- meson
	mh_style = "miss_hit",
	-- mix
	-- mojo_format
	nginxfmt = "nginx-config-formatter",
	-- nickel
	-- nimpretty
	nixfmt = "nixfmt",
	nixpkgs_fmt = "nixpkgs-fmt",
	nomad_fmt = "nomad",
	-- nph
	["npm-groovy-lint"] = "npm-groovy-lint",
	-- nufmt
	ocamlformat = "ocamlformat",
	-- ocp-indent
	odinfmt = "ols",
	opa_fmt = "opa",
	-- openapi_format
	ormolu = "ormolu",
	-- packer_fmt
	["palantir-java-format"] = "palantir-java-format",
	["panache-fix"] = "panache",
	-- pangu
	-- pasfmt
	-- perlimports
	-- perltidy
	pg_format = "pgformatter",
	php_cs_fixer = "php-cs-fixer",
	phpcbf = "phpcbf",
	-- phpinsights
	pint = "pint",
	-- pkl
	prettier = "prettier",
	prettierd = "prettierd",
	["pretty-php"] = "pretty-php",
	prettypst = "prettypst",
	-- prolog
	-- pruner
	-- puppet-lint
	["purs-tidy"] = "purescript-tidy",
	-- pycln
	pyink = "pyink",
	pymarkdownlnt = "pymarkdownlnt",
	["pyproject-fmt"] = "pyproject-fmt",
	-- python-ly
	-- pyupgrade
	-- qmlformat
	-- racketfmt
	["reformat-gherkin"] = "reformat-gherkin",
	["reorder-python-imports"] = "reorder-python-imports",
	-- rescript-format
	-- roc
	-- rstfmt
	rubyfmt = "rubyfmt",
	ruff_fix = "ruff",
	ruff_format = "ruff",
	ruff_organize_imports = "ruff",
	rufo = "rufo",
	-- runic
	-- rustfmt Deprecated by mason
	rustywind = "rustywind",
	-- scalafmt
	shellcheck = "shellcheck",
	shellharden = "shellharden",
	shfmt = "shfmt",
	sleek = "sleek",
	-- smlfmt
	snakefmt = "snakefmt",
	-- spotless_gradle
	-- spotless_maven
	sql_formatter = "sql-formatter",
	sqlfluff = "sqlfluff",
	sqlfmt = "sqlfmt",
	-- standard-clj
	standardjs = "standardjs",
	stylelint = "stylelint",
	-- styler
	-- stylish-haskell
	-- swift
	-- swift_format
	swiftformat = "swiftformat",
	swiftlint = "swiftlint",
	syntax_tree = "stree",
	tclfmt = "tclint",
	terraform_fmt = "terraform",
	-- terragrunt_hclfmt
	["tex-fmt"] = "tex-fmt",
	tlint = "tlint",
	-- tofu_fmt
	-- treefmt
	-- trunk
	["twig-cs-fixer"] = "twig-cs-fixer",
	-- txtpbfmt
	typespec = "tsp-server",
	typos = "typos",
	-- typstfmt
	typstyle = "typstyle",
	-- ufmt
	-- uncrustify
	usort = "usort",
	-- v
	vsg = "vsg",
	xmlformat = "xmlformatter",
	xmlformatter = "xmlformatter",
	-- xmllint
	-- xmlstarlet
	yamlfix = "yamlfix",
	yamlfmt = "yamlfmt",
	yapf = "yapf",
	-- yew-fmt
	yq = "yq",
	-- zigfmt -- no mason package; `zig fmt` ships with the zig toolchain
	-- ziggy
	-- ziggy_schema
	zprint = "zprint",

	-- nvim-lint linters
	actionlint = "actionlint",
	alex = "alex",
	-- ameba
	ansible_lint = "ansible-lint",
	bandit = "bandit",
	-- bash
	-- bean_check
	biomejs = "biome",
	-- blocklint
	buf_lint = "buf",
	cfn_lint = "cfn-lint",
	-- cfn_nag
	-- checkbashisms
	checkmake = "checkmake",
	-- checkpatch
	checkstyle = "checkstyle",
	-- chktex
	-- clangtidy -- no mason package; ships with the clang/LLVM toolchain
	-- clazy
	-- clippy
	["clj-kondo"] = "clj-kondo",
	cmake_lint = "cmakelang",
	cmakelint = "cmakelint",
	commitlint = "commitlint",
	-- cppcheck
	cpplint = "cpplint",
	-- credo
	cspell = "cspell",
	curlylint = "curlylint",
	-- dash
	-- dclint
	-- deadnix
	deno = "deno",
	detekt = "detekt",
	-- dialyxir
	dmypy = "mypy",
	dotenv_linter = "dotenv-linter",
	-- dxc
	["editorconfig-checker"] = "editorconfig-checker",
	erb_lint = "erb-lint",
	eugene = "eugene",
	-- fennel
	-- fieldalignment
	-- fish
	flake8 = "flake8",
	-- flawfinder
	-- fsharplint
	-- gawk
	gdlint = "gdtoolkit",
	-- ghdl
	gitleaks = "gitleaks",
	gitlint = "gitlint",
	-- glslc
	golangcilint = "golangci-lint",
	hadolint = "hadolint",
	-- herb
	-- hledger
	hlint = "hlint",
	htmlhint = "htmlhint",
	-- inko
	-- janet
	-- jshint
	-- json5
	jsonlint = "jsonlint",
	-- ksh
	-- lacheck
	-- languagetool
	-- lint-openapi
	-- ls_lint
	-- lslint
	-- luac
	luacheck = "luacheck",
	-- mado
	-- mago_analyze
	-- mago_lint
	markuplint = "markuplint",
	mbake = "mbake",
	mh_lint = "miss_hit",
	-- mlint
	mypy = "mypy",
	-- nagelfar
	-- nix
	["oelint-adv"] = "oelint-adv",
	opa_check = "opa",
	-- perlcritic
	-- perlimports
	pflake8 = "pyproject-flake8",
	-- php
	phpcs = "phpcs",
	-- phpinsights
	phpmd = "phpmd",
	phpstan = "phpstan",
	-- pmd
	-- pony
	-- prisma-lint
	proselint = "proselint",
	protolint = "protolint",
	-- puppet-lint
	-- pycodestyle
	pydocstyle = "pydocstyle",
	pylint = "pylint",
	["quick-lint-js"] = "quick-lint-js",
	-- redocly
	revive = "revive",
	-- rflint
	-- robocop
	rpmlint = "rpmlint",
	-- rpmspec
	rstcheck = "rstcheck",
	-- rstlint
	-- ruby
	saltlint = "salt-lint",
	selene = "selene",
	slang = "slang",
	-- snakemake
	snyk_iac = "snyk",
	solhint = "solhint",
	["sphinx-lint"] = "sphinx-lint",
	squawk = "squawk",
	staticcheck = "staticcheck",
	-- svlint
	-- systemd-analyze
	systemdlint = "systemdlint",
	tclint = "tclint",
	terraform_validate = "terraform",
	tfsec = "tfsec",
	-- tidy
	-- tofu
	trivy = "trivy",
	trivy_secret = "trivy",
	["ts-standard"] = "ts-standard",
	twigcs = "twigcs",
	-- unmake
	-- vala_lint
	vale = "vale",
	-- verilator
	vint = "vint",
	vulture = "vulture",
	woke = "woke",
	write_good = "write-good",
	yamllint = "yamllint",
	-- zig
	zlint = "zlint",
	-- zsh
}
