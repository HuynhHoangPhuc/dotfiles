# Codebase Summary

## Directory Structure Overview

```
dotfiles/
├── flake.nix                  # Main flake entry point; declares 11 inputs and all configs
├── flake.lock                 # Pinned dependency versions (committed to git)
├── configuration.nix          # Top-level: calls mkSystem to build each platform config
├── stylua.toml                # StyLua Lua formatter configuration
├── README.md                  # Project overview and quick start
├── LICENSE                    # MIT license
├── .envrc                      # Direnv config; loads flake shell
├── .gitignore                 # Git ignore rules
│
├── lib/                       # Utility functions and factories
│   ├── utils.nix              # eachSystem, eachSystemPassThrough helpers
│   └── mksystem.nix           # Factory function for building system configs
│
├── machines/                  # System-specific configurations
│   ├── darwin.nix             # Base macOS user config (minimal)
│   ├── macbook-air.nix        # MacBook Air specific: Homebrew apps, Touch ID
│   ├── nixos.nix              # Generic NixOS config: GRUB, Flathub, Snap
│   └── wsl.nix                # WSL2 specific: /mnt mounts, Start Menu launchers
│
├── home-manager/              # User-level declarative config (18 modules)
│   ├── default.nix            # Module aggregator; imports all 18 modules
│   ├── home.nix               # Core: username, home dir, session vars (EDITOR, PROJECTS)
│   ├── packages.nix           # System packages: ripgrep, fd, volta, 115+ dev tools
│   ├── zsh.nix                # Zsh shell + autocompletion + syntax highlighting
│   ├── starship.nix           # Starship prompt config
│   ├── ghostty.nix            # Ghostty terminal emulator config
│   ├── tmux.nix               # Tmux multiplexer: catppuccin, vim-navigator, yank
│   ├── git.nix                # Git: nvim editor, main branch, LFS, global gitignore
│   ├── lazygit.nix            # LazyGit TUI for git
│   ├── gh.nix                 # GitHub CLI: SSH protocol, nvim editor, 7 extensions
│   ├── delta.nix              # Delta: syntax highlighting for git diffs
│   ├── fzf.nix                # FZF fuzzy finder and keybindings
│   ├── zoxide.nix             # Zoxide: smart cd (replaces builtin cd)
│   ├── direnv.nix             # direnv + nix-direnv: auto-loads .env files
│   ├── eza.nix                # Eza: modern ls replacement with colors
│   ├── bat.nix                # Bat: modern cat replacement; batdiff, batman, batwatch
│   ├── go.nix                 # Go environment: GOPATH=~/Developer/Go
│   └── neovim.nix             # Neovim nightly + 20+ plugins + LSP + formatters + linters
│
└── config/                    # Application dotfiles
    ├── nvim/                  # Neovim Lua configuration
    │   ├── init.lua           # Entry point; conditional loading based on NVIM_APPNAME
    │   │
    │   ├── lua/
    │   │   ├── options.lua           # Editor settings: indent, colorcolumn=80, etc
    │   │   ├── keymaps.lua           # Leader=Space, system clipboard, LSP restart
    │   │   ├── plugins.lua           # Native vim.pack plugin declarations
    │   │   ├── icons.lua             # UI icons used across plugins
    │   │   ├── languageconfigs.lua   # Auto-discovers language/* configs
    │   │   │
    │   │   ├── packages/             # Mason auto-installer
    │   │   │   └── init.lua          # 600+ tool mappings (LSP, formatter, linter)
    │   │   │
    │   │   └── languages/            # Per-language configs (13 languages)
    │   │       ├── typescript.lua     # TypeScript/JavaScript: eslint, prettier, typescript-language-server
    │   │       ├── python.lua         # Python: pyright, ruff
    │   │       ├── go.lua             # Go: gopls, gofumpt, golangci-lint
    │   │       ├── c.lua              # C: clangd
    │   │       ├── cpp.lua            # C++: clangd
    │   │       ├── csharp.lua         # C#: omnisharp
    │   │       ├── lua.lua            # Lua: stylua
    │   │       ├── html.lua           # HTML: htmlhint
    │   │       ├── css.lua            # CSS: stylelint
    │   │       ├── tailwind.lua       # Tailwind CSS: tailwindcss-language-server
    │   │       ├── astro.lua          # Astro: astro-language-server
    │   │       ├── docker.lua         # Docker: dockerfile-language-server
    │   │       ├── nix.lua            # Nix: nil, nixfmt
    │   │       └── cmake.lua          # CMake: cmake-language-server
    │   │
    │   └── plugin/                   # Auto-loaded feature plugins
    │       ├── colorscheme.lua       # Catppuccin Mocha (pure black bg #000000)
    │       ├── picker.lua            # FZF-lua: C-p files, C-g grep, C-\ buffers
    │       ├── explorer.lua          # mini.files: dual-cache git status (10s/60s TTL)
    │       ├── completion.lua        # blink.cmp: Enter preset, LSP→Path→Snippets→Buffer
    │       ├── languageserver.lua    # LSP: attach hooks, keymaps (gra, grr, gri, gd)
    │       ├── treesitter.lua        # Treesitter: skip files >100KB, indent for C/CSS/HTML/TS
    │       ├── formatter.lua         # conform.nvim: format on save
    │       ├── linter.lua            # nvim-lint: debounced 100ms, on BufWritePost
    │       ├── git.lua               # gitsigns: hunk nav ]h/[h, stage/reset/blame
    │       ├── autopair.lua          # nvim-autopairs + nvim-ts-autotag: auto-pair brackets
    │       ├── surround.lua          # nvim-surround: cs/ds/ys operations
    │       ├── colorizer.lua         # nvim-colorizer: CSS/Tailwind color virtual text
    │       ├── indentation.lua       # indent-blankline: ▏ indentation guides
    │       └── copilot.lua           # GitHub Copilot (currently disabled)
    │
    ├── zsh/                   # Zsh shell configuration
    ├── starship/              # Starship prompt configuration
    ├── ghostty/               # Ghostty terminal configuration
    ├── tmux/                  # Tmux multiplexer configuration
    ├── lazygit/               # LazyGit configuration
    └── bat/                   # Bat (cat replacement) configuration
```

## Key Files Explained

### flake.nix
- Defines 11 inputs: nixpkgs-unstable, nix-darwin, nixos-wsl, home-manager, neovim-nightly, nix-snapd, nix-homebrew, homebrew-{core,cask,bundle}
- Exports 2 Darwin configs: `darwin`, `macbook-air`
- Exports 2 NixOS configs: `nixos`, `wsl`
- Each config combines system-level + home-manager config

### configuration.nix
- Calls `mkSystem` from lib/mksystem.nix for each platform
- Passes system type, machine config module, home-manager config as parameters
- Reduces boilerplate across Darwin/NixOS/WSL

### lib/mksystem.nix
Factory function pattern:
- Accepts `system`, `machineModule`, `homeManagerModule` as inputs
- Returns a system configuration combining both
- Used by configuration.nix to build all 4 platforms

### lib/utils.nix
Helper functions:
- `eachSystem` — Apply function to multiple architectures (aarch64-darwin, x86_64-linux, etc)
- `eachSystemPassThrough` — Pass architecture to nested functions

### machines/darwin.nix
Minimal macOS user configuration:
- Sets up basic home-manager modules
- Imported by macbook-air.nix

### machines/macbook-air.nix
MacBook Air specific:
- Imports darwin.nix base config
- Adds 20+ Homebrew apps: CLion, PyCharm, GoLand, VS Code, Brave, Ghostty, Docker Desktop, Office suite, Google Drive, Scroll Reverser, Zalo
- Enables Touch ID for sudo
- nix-homebrew integration

### machines/nixos.nix
Generic NixOS:
- System-level config: GRUB bootloader, kernel params
- Enables Flathub + Snap support
- Targets aarch64-linux and x86_64-linux

### machines/wsl.nix
WSL2 specific:
- Mounts Windows drives at /mnt
- Enables Start Menu app launchers
- Optimized for WSL2 environment

### home-manager/default.nix
Module aggregator:
- Imports all 18 home-manager modules
- Single point to enable/disable modules globally

### home-manager/home.nix
Core user config:
- Sets username, home directory path
- Session vars: EDITOR=nvim, PROJECTS=~/Developer
- Shell startup configuration

### home-manager/packages.nix
Development tools (115+ total):
- Build tools: make, cmake, gcc, clang, rustc
- Language runtimes: go, node (via volta), python
- LSP servers: typescript-language-server, pyright, gopls, clangd, omnisharp, nil, lua-language-server, html-language-server, css-language-server, tailwindcss-language-server, astro-language-server, dockerfile-language-server, cmake-language-server
- Formatters: prettier, ruff, gofmt, goimports, gofumpt, stylua, nixfmt, yamlfmt
- Linters: eslint, ruff, golangci-lint, yamllint, cmake-lint, tflint, shellcheck, hadolint
- Utilities: ripgrep, fd, jq, yq, curl, wget, git, git-lfs

### home-manager/neovim.nix
Neovim nightly configuration:
- Installs neovim-nightly (from flake overlay)
- Configures home.configFile to install lua/ and plugin/ configs
- Declares 20+ plugin dependencies
- Configures LSP, formatter, linter via language configs
- Enables 44 Treesitter parsers

### config/nvim/init.lua
Entry point:
- Conditional loading based on NVIM_APPNAME (support multiple neovim configs)
- Loads options.lua, keymaps.lua, plugins.lua, languageconfigs.lua

### config/nvim/lua/options.lua
Editor settings:
- indent: 4 spaces
- colorcolumn: 80 (right margin)
- line numbers, cursor position, mouse support, clipboard bindings

### config/nvim/lua/keymaps.lua
Keybindings:
- Leader key: Space
- System clipboard support (y to copy, p to paste)
- LSP restart shortcut
- Custom navigation bindings

### config/nvim/lua/plugins.lua
Native vim.pack declarations:
- Specifies 20+ plugins with optional start/on conditions
- No lazy.nvim; uses built-in plugin loading

### config/nvim/lua/languageconfigs.lua
Auto-discovery pattern:
- Scans lua/languages/ directory
- Loads {language}.lua config for each
- Applies LSP, formatter, linter settings per-language

### config/nvim/lua/languages/*.lua
Per-language setup (13 total):
- typescript.lua: LSP (typescript-language-server), formatter (prettier), linter (eslint)
- python.lua: LSP (pyright), formatter+linter (ruff)
- go.lua: LSP (gopls), formatters (gofumpt, goimports), linter (golangci-lint)
- etc.
- Each auto-discovered by languageconfigs.lua

### config/nvim/plugin/colorscheme.lua
Theme setup:
- Catppuccin Mocha theme
- Pure black background (#000000)
- Applies to UI, syntax highlighting

### config/nvim/plugin/picker.lua
FZF-lua integration:
- C-p: Find files
- C-g: Live grep (search code)
- C-\: Switch buffers

### config/nvim/plugin/explorer.lua
File explorer (mini.files):
- Dual-cache git status: 10s fast TTL, 60s slow TTL
- Shows git diff gutter in explorer

### config/nvim/plugin/completion.lua
Snippet & completion (blink.cmp):
- Enter preset (completion on enter)
- Priority: LSP → file paths → snippets → buffer words

### config/nvim/plugin/languageserver.lua
LSP configuration:
- On attach handlers (keymaps, formatting)
- LSP keymaps: gra (rename), grr (references), gri (implementation), gd (definition)
- Diagnostic display

### config/nvim/plugin/treesitter.lua
Syntax highlighting:
- Skip files > 100KB for performance
- Indent support for C, CSS, HTML, TypeScript
- 44 parsers pre-installed

### config/nvim/plugin/formatter.lua
Code formatting:
- conform.nvim integration
- Format on save
- Per-language formatters (prettier, ruff, gofumpt, stylua, etc)

### config/nvim/plugin/linter.lua
Linting:
- nvim-lint integration
- Debounced 100ms (avoid excessive reruns)
- On BufWritePost trigger
- Per-language linters (eslint, ruff, golangci-lint, etc)

### config/nvim/plugin/git.lua
Git integration (gitsigns):
- Hunk navigation: ]h (next), [h (prev)
- Stage/reset/blame operations
- Diff highlights in editor gutter

### config/nvim/plugin/autopair.lua
Auto-pairing:
- nvim-autopairs: auto-close brackets, parens, quotes
- nvim-ts-autotag: auto-close HTML/JSX tags

### config/nvim/plugin/surround.lua
Surround operations (nvim-surround):
- cs (change surround): cs"' changes "text" to 'text'
- ds (delete surround): ds" removes quotes
- ys (add surround): ysw" surrounds word with quotes

### config/nvim/plugin/colorizer.lua
Color highlighting (nvim-colorizer):
- Shows colors inline: #FF0000 renders red
- Tailwind CSS color support

### config/nvim/plugin/indentation.lua
Indentation guides (indent-blankline):
- ▏ character for vertical guides
- Visual indentation clarity

## Development Workflow

1. **Edit dotfiles** in config/ or home-manager/
2. **Run `dot-switch`** (alias for `darwin-rebuild switch + zsh refresh`)
3. **Verify changes** applied
4. **Commit changes** to git

## Supported Architectures & Platforms

| Config | Arch | Platform | Manager | Status |
|--------|------|----------|---------|--------|
| darwin | aarch64-darwin | macOS | Nix | Supported |
| macbook-air | aarch64-darwin | macOS | Nix + Homebrew | Primary |
| nixos | aarch64-linux, x86_64-linux | NixOS | Nix | Supported |
| wsl | x86_64-linux | WSL2 | Nix | Supported |

## Font Configuration

6 Nerd Fonts available:
- Fira Code Nerd Font
- Recursive Mono Nerd Font
- Monaspace Nerd Font
- Martian Mono Nerd Font
- Code New Roman Nerd Font
- JetBrains Mono Nerd Font

Used by: Terminal (Ghostty), Editor (Neovim), Tmux

## Version Pinning

- Home Manager state version: 26.05
- Darwin version: 6
- NixOS version: 25.11
- Neovim: nightly (latest stable from master)
- flake.lock: Committed to git for reproducibility

## Performance Notes

- Neovim startup: < 1 second (native vim.pack, no lazy.nvim overhead)
- Treesitter: Skips files > 100KB to prevent slowdown
- Linter: Debounced 100ms to avoid excessive CPU usage
- File explorer git status: Dual-cache (10s fast, 60s slow) for responsiveness
