# Project Overview & Product Development Requirements

## Executive Summary

Personal dotfiles repository using **Nix Flakes** and **Home Manager** to achieve reproducible, declarative system configuration across multiple platforms (macOS, NixOS, WSL2). The project prioritizes developer ergonomics, tool consistency, and single-source-of-truth configuration.

## Project Goals

1. **Reproducibility**: Identical development environment across machines via pinned dependencies
2. **Declarative Configuration**: All system and user config expressed as Nix code (no imperative scripts)
3. **Multi-platform Parity**: Unified configuration patterns for Darwin, NixOS, and WSL2
4. **Developer Velocity**: Auto-install 115+ LSP/formatter/linter tools; single keybinding set across editors
5. **Maintainability**: Modular structure; easy to add/remove platforms or tools

## Key Architectural Decisions

### 1. Flake-based Architecture
- **11 pinned inputs** ensures reproducible builds across time
- nix-darwin (macOS), nixos-wsl (WSL2), home-manager (user config) as separate inputs
- flake.lock committed to git for version pinning

### 2. mkSystem Factory Pattern
- **lib/mksystem.nix** provides reusable system builder
- Eliminates duplication between Darwin, NixOS, WSL configs
- Accepts system type, configuration module, home-manager config as parameters

### 3. Home Manager Module Aggregation
- **home-manager/default.nix** imports 18 modules
- Each module (zsh.nix, neovim.nix, git.nix, etc) is self-contained
- Modules can be disabled/enabled globally or per-system

### 4. Native vim.pack for Neovim
- Avoids lazy.nvim; uses built-in plugin loading
- Reduces startup overhead; easier to debug plugin interactions
- Plugin configs organized in **config/nvim/plugin/** directory

### 5. Nightly Neovim via Flake Overlay
- neovim-nightly input provides latest stable from master
- Allows testing new features before stable release

### 6. Catppuccin Mocha as Default Theme
- Consistent across Neovim, Tmux, terminal apps
- Pure black background (#000000) for OLED optimization

## Platform-Specific Design

### macOS (Darwin)
- `darwinConfigurations.darwin` — Minimal generic config
- `darwinConfigurations.macbook-air` — Full config with Homebrew apps (CLion, PyCharm, Docker Desktop, etc)
- Touch ID sudo via darwin config
- nix-homebrew integration for package management

### NixOS
- `nixosConfigurations.nixos` — Generic NixOS targeting aarch64/x86_64
- GRUB bootloader; Flathub + Snap support
- Full system + user configuration

### WSL2
- `nixosConfigurations.wsl` — WSL2 specific
- Mounts /mnt for Windows drive access
- Start Menu app launchers for GUI apps

## Component Overview

### Core Files
- **flake.nix** — Declares 11 inputs, defines system configurations
- **configuration.nix** — Calls mkSystem to build each platform
- **stylua.toml** — Lua formatter config (used by neovim module)

### lib/ — Utility Functions
- **utils.nix** — eachSystem, eachSystemPassThrough for cross-platform builds
- **mksystem.nix** — Factory for building system configs

### machines/ — Platform Configs
- **darwin.nix** — Base macOS user config (minimal)
- **macbook-air.nix** — MacBook Air specific (imports darwin.nix, adds Homebrew apps)
- **nixos.nix** — NixOS system config
- **wsl.nix** — WSL2 system config

### home-manager/ — User-Level Config (18 Modules)
- **home.nix** — Core: username, home dir, session variables
- **packages.nix** — System packages (ripgrep, fd, volta, 115+ dev tools)
- **zsh.nix** — Shell + autocompletion + syntax highlighting
- **neovim.nix** — Editor with 20+ plugins, LSP, formatters, linters
- **tmux.nix** — Terminal multiplexer with Catppuccin theme
- **git.nix** — Git config, LFS, global gitignore
- **starship.nix** — Prompt configuration
- **ghostty.nix** — Terminal emulator config
- **gh.nix** — GitHub CLI with extensions
- **lazygit.nix** — Git UI
- **fzf.nix** — Fuzzy finder
- **zoxide.nix** — Smart directory navigation
- **direnv.nix** — Auto-load .env files via nix-direnv
- **delta.nix** — Git diff syntax highlighter
- **eza.nix** — Modern ls replacement
- **bat.nix** — Modern cat replacement
- **go.nix** — Go environment
- **others** — lesser modules

### config/ — Application Configurations
- **config/nvim/** — Neovim Lua config
  - init.lua, options.lua, keymaps.lua, plugins.lua
  - lua/languages/ — Per-language LSP/format/lint configs (13 languages)
  - lua/packages/ — Mason auto-installer with 600+ tool mappings
- **config/zsh/** — Zsh configuration
- **config/starship/** — Starship prompt config
- **config/ghostty/** — Terminal config
- **config/tmux/** — Tmux config
- **config/bat/** — Bat config
- **config/lazygit/** — LazyGit config

## Functional Requirements

### FR1: Multi-Platform Support
- Support macOS, NixOS, WSL2 from single flake
- Platform-specific apps installed via appropriate package managers (Nix, Homebrew, etc)

### FR2: Reproducible Development Environment
- 115+ LSP servers, formatters, linters auto-installed
- Languages: TypeScript/JS (Volta), Python, Go, Lua, C/C++, C#, Nix, others
- Same versions across all machines

### FR3: Declarative Configuration
- All dotfiles (shell, editor, git, tmux, etc) declared in Nix
- No manual config file edits needed
- Configuration drift prevented

### FR4: Plugin Management for Neovim
- 20+ plugins installed and configured
- 44 Treesitter parsers
- 13 per-language LSP/formatter/linter configs
- Auto-plugin discovery via lua/languages/

### FR5: Theme Consistency
- Catppuccin Mocha applied to:
  - Neovim colorscheme
  - Tmux status bar and colors
  - Terminal apps (Ghostty)
- Pure black background (#000000)

### FR6: Integrated Development Tools
- FZF picker integration (C-p files, C-g grep, C-\ buffers)
- Git integration via gitsigns, delta, lazygit
- LSP shortcuts (gra rename, grr references, gd definition, etc)
- Direnv for per-project Nix shells

## Non-Functional Requirements

### NFR1: Maintainability
- Modular file structure; each component has single responsibility
- Home-manager modules can be toggled on/off
- LSP/formatter/linter configs auto-discovered

### NFR2: Performance
- Neovim startup < 1 second
- Treesitter skips files > 100KB
- Mini.files git status dual-cache (10s fast TTL, 60s slow TTL)
- Linter debounced 100ms

### NFR3: Developer Experience
- `dot-switch` alias for easy rebuilds
- Zsh autocompletion enabled
- Clear error messages on misconfiguration

### NFR4: Compatibility
- Home Manager state versions pinned (26.05)
- Darwin version 6
- NixOS version 25.11
- Fonts: 6 Nerd Fonts available

## Success Criteria

- All systems (Darwin, NixOS, WSL2) build without errors
- Development environment identical across machines
- Neovim LSP functionality verified for all 13 languages
- Formatters/linters working for supported languages
- Git workflow smooth (gitsigns, delta, lazygit integrated)
- Theme consistent across all apps
- Documentation current and accurate

## Current Implementation Status

- Flake structure complete with 11 inputs
- 4 system configurations defined (darwin, macbook-air, nixos, wsl)
- 18 home-manager modules implemented
- Neovim with full LSP/formatter/linter setup
- Tmux, Git, Zsh, FZF integrated
- Catppuccin theme applied
- 6 Nerd Fonts configured

## Future Enhancements

- Additional machine configurations (Linux desktop, custom NixOS)
- Helix editor integration (alternative to Neovim)
- Additional language support (Rust, Kotlin, Swift)
- Development container configurations for per-project shells
- CI/CD pipeline for flake validation
- Installation script for new machines
