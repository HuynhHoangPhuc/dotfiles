# Dotfiles

Personal dotfiles repository with declarative system configuration using **Nix Flakes** and **Home Manager**.

## Features

- **Multi-platform**: Unified configuration for macOS (Darwin), NixOS, and WSL2 (Linux)
- **Reproducible**: Pinned dependencies via flake.lock for consistent environments
- **User-level**: Home Manager for declarative package and dotfile management
- **Development-focused**: 115+ LSP/formatter/linter tools auto-installed
- **Theming**: Catppuccin Mocha across Neovim, Tmux, and terminal configs
- **Smart tooling**: FZF, direnv, zoxide, git integration

## Supported Systems

- **macOS**: Generic Darwin config + MacBook Air variant with Homebrew apps
- **NixOS**: Generic NixOS config with Flathub/Snap support
- **WSL2**: WSL-specific configuration with mount options and Start Menu launchers

## Quick Start

### Clone Repository
```bash
git clone <repo-url> ~/.config/nixpkgs
cd ~/.config/nixpkgs
```

### Darwin (macOS)
```bash
nix flake update                          # Update flake.lock
nix run nix-darwin -- switch --flake .#macbook-air
dot-switch                                 # Alias for rebuild + zsh refresh
```

### NixOS
```bash
sudo nixos-rebuild switch --flake .#nixos
```

### WSL2
```bash
sudo nixos-rebuild switch --flake .#wsl
```

## Key Configuration Files

- **flake.nix** — 11 inputs (nixpkgs-unstable, nix-darwin, nixos-wsl, home-manager, etc)
- **configuration.nix** — System config builder using mkSystem factory
- **home-manager/** — User-level packages, shell, editor, tools (18 modules)
- **config/nvim/** — Neovim with LSP, formatters, linters, 20+ plugins
- **machines/** — System-specific configs (darwin.nix, macbook-air.nix, nixos.nix, wsl.nix)

## Development Environment

Auto-installed tools include:
- **Languages**: Go, Lua, TypeScript/Node (via Volta), Python
- **LSP Servers**: TypeScript, Python (Pyright), Go (gopls), C/C++ (clangd), Nix, and 8+ others
- **Formatters**: prettier, ruff, stylua, gofumpt, nixfmt, yamlfmt
- **Linters**: eslint, ruff, golangci-lint, yamllint, cmake-lint

## Documentation

- [Project Overview & PDR](./docs/project-overview-pdr.md) — Goals, decisions, architecture
- [Codebase Summary](./docs/codebase-summary.md) — Directory structure, file purposes
- [Code Standards](./docs/code-standards.md) — Nix & Lua conventions
- [System Architecture](./docs/system-architecture.md) — Multi-platform design
- [Project Roadmap](./docs/project-roadmap.md) — Current state and future plans

## License

MIT — See LICENSE file
