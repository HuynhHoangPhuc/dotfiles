# System Architecture

## Overview

This document describes the multi-platform architecture of the dotfiles repository. The system uses **Nix Flakes** as the dependency/build orchestrator and **Home Manager** for user-level configuration across macOS, NixOS, and WSL2.

## Architectural Layers

```
┌─────────────────────────────────────────────────────────────┐
│                   User Applications Layer                    │
│  Neovim | Tmux | Zsh | Git | FZF | LazyGit | Ghostty       │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────┐
│              Home Manager Configuration Layer                │
│  (18 Modules: packages, shell, editor, tools, themes)       │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────┐
│           mkSystem Factory & System Configuration           │
│  (Platform-specific: darwin.nix, nixos.nix, wsl.nix)        │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────┐
│              Nix Flake Orchestration Layer                   │
│  (11 inputs: nixpkgs, nix-darwin, nixos-wsl, etc)           │
└─────────────────────────────────────────────────────────────┘
```

## Nix Flake Architecture

### Input Dependencies (11 total)

| Input | Purpose | Architecture |
|-------|---------|--------------|
| nixpkgs-unstable | Core packages for all platforms | aarch64-darwin, x86_64-linux, aarch64-linux |
| nix-darwin | macOS system config | aarch64-darwin |
| nixos-wsl | WSL2-specific system config | x86_64-linux |
| home-manager | User-level declarative config | All platforms |
| neovim-nightly | Latest Neovim build | All platforms |
| nix-snapd | Snapcraft integration for NixOS | x86_64-linux |
| nix-homebrew | Homebrew integration for macOS | aarch64-darwin |
| homebrew-core | Homebrew package core | aarch64-darwin |
| homebrew-cask | Homebrew GUI applications | aarch64-darwin |
| homebrew-bundle | Homebrew bundle automation | aarch64-darwin |

### Flake Outputs

```nix
outputs = { flake-utils, ... }:
  flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ] (system:
    {
      darwinConfigurations = {
        darwin = mkSystem { ... };           # Generic macOS
        macbook-air = mkSystem { ... };      # MacBook Air + Homebrew
      };

      nixosConfigurations = {
        nixos = mkSystem { ... };             # Generic NixOS
        wsl = mkSystem { ... };               # WSL2 specific
      };
    }
  );
```

### Build Output

Each configuration produces:
- **System closure:** All system packages, kernel, bootloader (NixOS only)
- **Home Manager closure:** User packages, dotfiles, environment variables
- **Activation script:** Script to apply configuration

## mkSystem Factory Pattern

### Factory Definition (lib/mksystem.nix)

```nix
mkSystem = { system, machineModule, homeManagerModule }:
  let
    pkgs = import nixpkgs { inherit system; overlays = [ ... ]; };
  in
  # Darwin config
  if isDarwin system then
    nix-darwin.lib.darwinSystem {
      inherit pkgs;
      modules = [ machineModule homeManagerModule ];
    }
  # NixOS config
  else
    nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = [ machineModule homeManagerModule ];
    };
```

### Factory Usage (configuration.nix)

```nix
darwinConfigurations.macbook-air = mkSystem {
  system = "aarch64-darwin";
  machineModule = ./machines/macbook-air.nix;
  homeManagerModule = ./home-manager;
};

nixosConfigurations.wsl = mkSystem {
  system = "x86_64-linux";
  machineModule = ./machines/wsl.nix;
  homeManagerModule = ./home-manager;
};
```

## Configuration Composition

### System Configuration Chain

```
configuration.nix
    ↓
mkSystem factory
    ├─ machineModule (darwin.nix, macbook-air.nix, nixos.nix, wsl.nix)
    │   └─ Sets system-level: bootloader, kernel, packages, hardware
    └─ homeManagerModule (home-manager/default.nix)
        └─ Imports 18 user-level modules
            ├─ home.nix (core: username, home dir, env vars)
            ├─ packages.nix (115+ dev tools)
            ├─ zsh.nix (shell + completion)
            ├─ neovim.nix (editor + plugins)
            ├─ tmux.nix (multiplexer)
            ├─ git.nix (version control)
            └─ ... (12 more modules)
```

### Module Aggregation (home-manager/default.nix)

```nix
{ config, lib, pkgs, ... }:
{
  imports = [
    ./home.nix
    ./packages.nix
    ./zsh.nix
    ./neovim.nix
    ./tmux.nix
    ./git.nix
    # ... 12 more imports
  ];
}
```

**Pattern:** Each module:
1. Declares `options` (if configurable)
2. Implements `config` conditionally via `lib.mkIf`
3. Can be toggled on/off globally

## Home Manager Module System

### Module Structure

Each home-manager module:
- **Input:** `{ config, lib, pkgs, ... }`
- **Output:** `{ options = { ... }; config = { ... }; }`
- **Activation:** Applied in dependency order

### Common Module Patterns

**Simple package module:**
```nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.ripgrep pkgs.fd ];
}
```

**Feature with configuration:**
```nix
{ config, lib, pkgs, ... }:
{
  options.programs.myapp.enable = lib.mkEnableOption "myapp";

  config = lib.mkIf config.programs.myapp.enable {
    home.packages = [ pkgs.myapp ];
    xdg.configFile."myapp/config".source = ./myapp.conf;
  };
}
```

**Environment setup:**
```nix
{ ... }:
{
  home.sessionVariables = {
    EDITOR = "nvim";
    PROJECTS = "$HOME/Developer";
  };
}
```

## Neovim Architecture

### Plugin System

Neovim uses **native vim.pack** (not lazy.nvim):

```
config/nvim/
├── lua/pack/             # Installed plugins (auto-discovered)
│   ├── nvim-treesitter/
│   ├── blink.cmp/
│   └── ... (20+ plugins)
├── init.lua              # Entry point
├── lua/
│   ├── options.lua       # Editor settings
│   ├── keymaps.lua       # Keybindings
│   ├── plugins.lua       # Plugin declarations
│   └── languageconfigs.lua  # Auto-discover languages/*
└── plugin/               # Auto-loaded on startup
    ├── colorscheme.lua
    ├── lsp.lua
    └── ... (13 features)
```

### Language Configuration Auto-Discovery

**Flow:**
1. `init.lua` loads `languageconfigs.lua`
2. `languageconfigs.lua` scans `lua/languages/` directory
3. For each `{language}.lua`:
   - Requires the module
   - Extracts `lsp`, `formatter`, `linter` config
   - Registers with LSP server (lspconfig)
   - Configures formatter (conform.nvim)
   - Configures linter (nvim-lint)

**Example (typescript.lua):**
```lua
local M = {}

M.lsp = {
  server_name = "typescript-language-server",
  settings = { ... },
}

M.formatter = "prettier"
M.linter = "eslint"

return M
```

### Plugin Load Order

1. **init.lua** — Entry point, loads options/keymaps/plugins
2. **lua/plugins.lua** — Declares 20+ plugins with vim.pack
3. **plugin/** (13 files) — Auto-loaded on startup, initializes each plugin
4. **lua/languages/** (13 files) — Auto-discovered, registers LSP/formatter/linter per language

### LSP Integration

**LSP Architecture:**
```
nvim-lspconfig
    ├─ typescript-language-server
    ├─ pyright (Python)
    ├─ gopls (Go)
    ├─ clangd (C/C++)
    ├─ omnisharp (C#)
    ├─ nil (Nix)
    └─ ... (8+ servers)
```

**On Attach Keymaps:**
- `gra` — Rename symbol
- `grr` — Find references
- `gri` — Find implementations
- `gd` — Go to definition
- Others: hover, code actions, workspace symbols

### Formatter Integration

**conform.nvim** handles:
- Format on save (BufWritePre)
- Per-filetype formatter routing
- Fallback to next formatter if first fails

**Supported formatters:**
- TypeScript/JavaScript: prettier
- Python: ruff
- Go: gofumpt, goimports
- Lua: stylua
- Nix: nixfmt
- Others: yamlfmt, htmlhint, stylelint

### Linter Integration

**nvim-lint** handles:
- On-write linting (BufWritePost, 100ms debounce)
- Async diagnostic display
- Per-filetype linter routing

**Supported linters:**
- TypeScript/JavaScript: eslint
- Python: ruff
- Go: golangci-lint
- YAML: yamllint
- Others: cmake-lint, tflint, shellcheck, hadolint

## Platform-Specific Architecture

### macOS (Darwin) Flow

```
flake.nix (macbook-air)
    ↓
mkSystem {
  system = "aarch64-darwin"
  machineModule = machines/macbook-air.nix
}
    ↓
nix-darwin.lib.darwinSystem
    ├─ System config (darwin.nix: minimal)
    └─ Home Manager
        ├─ home-manager/default.nix (18 modules)
        └─ Homebrew apps (via nix-homebrew)
```

**Homebrew Integration:**
- nix-homebrew provides declarative Homebrew config
- Installs CLI tools + GUI apps (CLion, PyCharm, Docker Desktop, etc)
- Managed alongside Nix packages

### NixOS Flow

```
flake.nix (nixos)
    ↓
mkSystem {
  system = "aarch64-linux" / "x86_64-linux"
  machineModule = machines/nixos.nix
}
    ↓
nixpkgs.lib.nixosSystem
    ├─ System config (bootloader, kernel, services)
    ├─ Home Manager
    │   └─ home-manager/default.nix (18 modules)
    └─ Flathub/Snap support
```

### WSL2 Flow

```
flake.nix (wsl)
    ↓
mkSystem {
  system = "x86_64-linux"
  machineModule = machines/wsl.nix
}
    ↓
nixpkgs.lib.nixosSystem (limited WSL support)
    ├─ System config (WSL-specific: /mnt mounts, interop)
    └─ Home Manager
        └─ home-manager/default.nix (18 modules)
```

**WSL-Specific Features:**
- Windows drive mounted at `/mnt`
- Start Menu integration for GUI apps
- No bootloader/kernel management
- Nix provides all application layer

## Data Flow

### Build Time

```
flake.nix + flake.lock
    ↓
nix flake update (update pinned versions)
    ↓
configuration.nix (calls mkSystem)
    ↓
mkSystem factory (instantiates 4 configs)
    ├─ macbook-air.nix
    ├─ nixos.nix
    └─ wsl.nix
    ↓
home-manager/default.nix (imports 18 modules)
    ├─ Resolves all package dependencies
    ├─ Generates activation script
    └─ Computes closure
    ↓
Build output (ready to activate)
```

### Activation (Runtime)

```
darwin-rebuild switch --flake .#macbook-air
    ↓
Applies system config changes
    ↓
Runs Home Manager activation
    ├─ Writes dotfiles to ~/.config/
    ├─ Installs packages via Nix
    ├─ Sets environment variables
    └─ Refreshes shell
    ↓
Changes live (new terminal sessions see config)
```

## Dependency Graph

### Critical Path
1. **flake.nix** — All configs depend on flake definition
2. **lib/mksystem.nix** — All system configs use factory
3. **machines/{platform}.nix** — Platform-specific bootloader/hardware
4. **home-manager/default.nix** — User packages + config
5. **home-manager/neovim.nix** — Installs nvim + Lua config
6. **config/nvim/** — Lua files symlinked by home.nix

### Circular Dependency Prevention
- flake.nix inputs don't depend on local code (only pinned versions)
- Home Manager modules don't depend on each other (aggregated in default.nix)
- Neovim Lua configs don't import each other (loaded sequentially)

## Overlay System

### Neovim Nightly Overlay

```nix
overlays.neovim-overlay = final: prev: {
  neovim = final.neovim-nightly;
};
```

**Effect:**
- Uses latest neovim-nightly from flake input
- Overrides nixpkgs.neovim with nightly build
- Ensures recent features/fixes available

### Package Override Pattern

```nix
# Example: Force specific package version
pkgs.override {
  overrides = {
    mypackage = { ... };
  };
}
```

## Configuration Profiles

The repository supports 4 distinct profiles:

| Profile | System | Arch | Use Case |
|---------|--------|------|----------|
| `darwin` | macOS | aarch64-darwin | Minimal macOS |
| `macbook-air` | macOS | aarch64-darwin | Primary workstation |
| `nixos` | NixOS | aarch64-linux, x86_64-linux | Full system control |
| `wsl` | WSL2 | x86_64-linux | Development on Windows |

Each profile:
- Maintains separate system closure
- Shares home-manager user config (18 modules)
- Can be independently switched to

## Deployment Model

### Pull-Based Configuration

```
Local machine
    ↓
Clone/update git repo
    ↓
nix flake update (optional: update inputs)
    ↓
darwin-rebuild switch / nixos-rebuild switch
    ↓
Evaluate flake for current system
    ↓
Build closure + download prebuilt binaries
    ↓
Activate changes (Nix GC handles cleanup)
```

### State Management

**Managed by Nix:**
- Installed packages (in /nix/store)
- Symlinked dotfiles (~/.config, ~/.*)
- Environment variables

**Not Managed by Nix:**
- User data files (~/.local/share)
- Git repositories
- Build artifacts

## Performance Characteristics

### Build Time
- **First build:** 5-15 minutes (downloads binary cache)
- **Incremental:** < 1 minute (cached packages)
- **No changes:** < 10 seconds (evaluate only)

### Runtime Overhead
- **Shell startup:** < 500ms (zsh + plugins)
- **Neovim startup:** < 1 second (native vim.pack)
- **Lazy loading:** Deferred for non-essential plugins

### Storage
- **/nix/store:** 5-10 GB (all Nix packages)
- **~/.config:** < 100 MB (dotfiles)
- **~/.cache:** Variable (treesitter caches, etc)

## Security Architecture

### Secret Management

**Current approach:**
- SSH keys stored in ~/.ssh (manual)
- Git credentials via SSH (no stored passwords)
- API keys in shell history disabled

**Recommended future approach:**
- Use 1Password/Vault for secret injection
- Sops-nix for encrypted secrets in flake

### Package Verification

- flake.lock pins exact package versions
- Nix verifies hash of each downloaded package
- Homebrew on macOS verifies signatures

## Evolution & Extensibility

### Adding New Machines

1. Create `machines/mynewmachine.nix`
2. Add to `configuration.nix` via `mkSystem { system = ...; machineModule = ...; }`
3. Run `nix flake show` to verify

### Adding New Languages to Neovim

1. Create `config/nvim/lua/languages/mylang.lua` with LSP/formatter/linter config
2. LSP server auto-discovered by `languageconfigs.lua`
3. No changes needed to init.lua or plugins.lua

### Adding New Home Manager Module

1. Create `home-manager/mymodule.nix`
2. Import in `home-manager/default.nix`
3. Rebuild: `darwin-rebuild switch --flake .`

### Adding New Global Package

1. Add to `home-manager/packages.nix` in `home.packages`
2. Rebuild: `darwin-rebuild switch --flake .`
