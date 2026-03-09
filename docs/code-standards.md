# Code Standards & Conventions

## Overview

This document defines coding conventions for the dotfiles repository. The project uses two primary languages: **Nix** (for system/user configuration) and **Lua** (for Neovim configuration).

## Nix Conventions

### File Organization

**Module Structure:**
```nix
# home-manager/mymodule.nix
{ config, lib, pkgs, ... }:

{
  options = {
    # Declare options here
  };

  config = {
    # Implementation here
  };
}
```

**Naming:**
- Files: kebab-case (e.g., `git.nix`, `neovim.nix`, `lazygit.nix`)
- Options: camelCase (e.g., `programs.git.enable`)
- Variables: camelCase (e.g., `pkgsList`, `enableFeature`)

### Formatting

- **Indentation:** 2 spaces (Nix standard)
- **Line length:** 80 columns (enforced by stylua.toml for mixed files)
- **Formatting tool:** nixfmt (auto-format Nix code)

### Module Pattern

All home-manager modules follow:

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

**Rules:**
- Always use `lib.mkIf` to conditionally apply config based on enable
- Use `lib.mkOption` for options with defaults
- Use `lib.mkEnableOption` for boolean toggles
- Specify `default = false` for optional features

### Home Manager Configuration

**Pattern for home.packages:**
```nix
home.packages = with pkgs; [
  ripgrep
  fd
  # ... sorted alphabetically
];
```

**Pattern for environment variables:**
```nix
home.sessionVariables = {
  EDITOR = "nvim";
  PROJECTS = "$HOME/Developer";
};
```

**Pattern for shell aliases:**
```nix
programs.zsh.shellAliases = {
  l = "eza -la";
  g = "lazygit";
};
```

### Import Organization

Within a module:
1. Declarative header comment (purpose of module)
2. Function signature: `{ config, lib, pkgs, ... }:`
3. Option definitions (if any)
4. Config implementation
5. Conditional application via `lib.mkIf`

### Comments

```nix
# Short single-line comments use #

# Multi-line comments explain the "why"
# not just the "what". Explain non-obvious
# design decisions or workarounds.
```

## Lua Conventions

### File Organization

**Neovim Config Structure:**
```
config/nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── options.lua             # Editor settings
│   ├── keymaps.lua             # Key bindings
│   ├── plugins.lua             # Plugin declarations
│   ├── icons.lua               # UI icons
│   ├── languageconfigs.lua     # Auto-discovery
│   ├── packages/
│   │   └── init.lua            # Mason tool mappings
│   └── languages/              # Per-language configs
│       ├── typescript.lua
│       ├── python.lua
│       └── ... (13 total)
└── plugin/                     # Auto-loaded plugins
    ├── colorscheme.lua
    ├── picker.lua
    └── ... (13 total)
```

**Naming:**
- Files: kebab-case (e.g., `colorscheme.lua`, `language-server.lua`)
- Variables: snake_case (e.g., `local_config`, `enable_feature`)
- Functions: snake_case (e.g., `setup_lsp()`, `configure_keymaps()`)
- Classes/tables: PascalCase for class-like objects (e.g., `Config`, `Handler`)

### Formatting

- **Indentation:** 2 spaces
- **Line length:** 80 columns (enforced by stylua.toml in repository)
- **Formatting tool:** stylua (auto-format Lua code via `stylua .`)
- **Style:** Roblox style per stylua defaults

### Module Pattern

**Standard plugin config:**
```lua
-- config/nvim/plugin/myplugin.lua
local ok, plugin = pcall(require, "myplugin")
if not ok then
  vim.notify("Failed to load myplugin", vim.log.levels.ERROR)
  return
end

plugin.setup({
  option1 = "value",
  option2 = true,
})
```

**Language config:**
```lua
-- config/nvim/lua/languages/mylang.lua
local M = {}

M.lsp = {
  server_name = "mylsp",
  settings = {
    -- LSP settings
  },
}

M.formatter = "myformatter"
M.linter = "mylinter"

return M
```

### Commenting

```lua
-- Single line comments use --

-- Multi-line comments explain the "why"
-- not the "what". Non-obvious code needs
-- explanation of design decisions.

-- Avoid obvious comments:
-- BAD: local x = 5  -- Set x to 5
-- GOOD: local threshold = 5  -- Cache invalidation interval (seconds)
```

### Variables & Naming

```lua
local private_var = "local scope"
public_var = "global scope (avoid unless necessary)"

-- Boolean prefixes: is_, has_, enable_, disable_
local is_enabled = true
local has_feature = false
local enable_debug = false

-- Config tables: use descriptive names
local lsp_settings = { ... }
local format_options = { ... }
```

### Error Handling

```lua
-- Use pcall for require statements
local ok, module = pcall(require, "module_name")
if not ok then
  vim.notify("Error loading module: " .. module, vim.log.levels.ERROR)
  return
end

-- Use vim.notify for user-facing errors
if error_condition then
  vim.notify("Something went wrong", vim.log.levels.WARN)
end
```

### LSP Configuration

```lua
-- config/nvim/lua/languages/typescript.lua
local M = {}

M.lsp = {
  server_name = "typescript-language-server",
  settings = {
    typescript = {
      inlayHints = {
        enabled = true,
        includeInlayParameterNameHints = "all",
      },
    },
  },
}

M.formatter = "prettier"
M.linter = "eslint"

return M
```

**Rules:**
- LSP server name must match nvim-lspconfig conventions
- Settings follow server-specific documentation
- Formatter/linter names must match conform.nvim/nvim-lint mappings
- Auto-discovered by lua/languageconfigs.lua

### Plugin Declarations

```lua
-- config/nvim/lua/plugins.lua
-- vim.pack style (no lazy.nvim)
local plugins = {
  {
    "author/plugin-name",
    config = function()
      require("plugin-name").setup({ ... })
    end,
    enabled = true,
  },
}

-- OR conditional loading:
{
  "author/plugin-name",
  ft = "typescript",  -- Only load for TypeScript files
  config = function() ... end,
}
```

### Keymaps

```lua
-- config/nvim/lua/keymaps.lua
local opts = { noremap = true, silent = true }

-- Leader key: Space
vim.g.mapleader = " "

-- Examples:
vim.keymap.set("n", "<leader>ff", "<cmd>Fzf<CR>", opts)
vim.keymap.set("n", "gra", vim.lsp.buf.rename, opts)

-- Mnemonic naming:
-- <leader>f* = file/find operations
-- <leader>g* = git/grep operations
-- <leader>s* = search/replace operations
-- g* = LSP/goto operations
```

## File Size Limits

- **Nix files:** No strict limit; prefer modules < 100 lines for readability
- **Lua files:** Keep under 200 lines; split larger features into separate files
- **Configuration imports:** Limit depth to 3 levels to avoid circular dependencies

## Documentation Standards

### Nix Documentation

```nix
# mymodule.nix
# Purpose: Configure application X with sensible defaults
# Dependencies: requires pkgs.X to be available
# Example usage:
#   programs.myapp.enable = true;
```

### Lua Documentation

```lua
-- Language config template
-- Purpose: TypeScript/JavaScript LSP + formatting + linting
-- Requires: typescript-language-server, prettier, eslint
-- Auto-loaded by: languageconfigs.lua
```

## Modularization Rules

### When to Extract
- Nix: If a home-manager module exceeds 100 lines, consider splitting concerns
- Lua: If a plugin config exceeds 200 lines, split into lua/ submodule
- Configuration: If per-language setup duplicates across multiple languages, extract to shared utility

### How to Organize
```
home-manager/myfeature/
├── default.nix          # Aggregator
├── shell.nix            # Shell-specific config
├── editor.nix           # Editor integration
└── packages.nix         # Dependencies

config/nvim/lua/languages/
├── base-lsp.lua         # Shared LSP utilities
├── typescript.lua       # Extends base-lsp
└── python.lua           # Extends base-lsp
```

## Git & Version Control

### Commit Messages

Use conventional commits:
```
chore(home-manager): add ripgrep and fd packages
feat(nvim): add TypeScript LSP with prettier formatter
fix(tmux): correct keybinding conflict
docs(readme): update quick start instructions
refactor(config): extract shared LSP utilities
test(flake): validate all system configs build
```

**Rules:**
- Type: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `perf`
- Scope: component being changed (nvim, tmux, zsh, flake, etc)
- Subject: lowercase, imperative tense, no period
- Body (if needed): explain the "why", not the "what"

### Files Never Committed
- `.envrc.local` — Local environment overrides
- Secrets or API keys — Use `flake.nix` inputs for sensitive data
- Build artifacts — Generated binaries or compiled outputs

## Testing & Validation

### Nix Validation

```bash
# Check flake syntax
nix flake check

# Validate all system configs build (dry run)
nix flake show

# Test specific config
darwin-rebuild switch --flake .#macbook-air --dry-run
```

### Lua Validation

```bash
# Format check (via stylua)
stylua --check config/nvim

# Auto-format
stylua config/nvim

# Linting (via luacheck, if available)
luacheck config/nvim
```

## Performance Guidelines

### Nix
- Avoid excessive imports in default.nix; lazy-load modules where possible
- Use `lib.mkIf` to condition expensive configs
- Keep flake.lock updated to ensure cached evaluations

### Lua
- Plugin configs: Use `ft` or `event` conditions to defer loading
- LSP: Use debounce for frequently-triggered handlers
- Treesitter: Skip files > 100KB (see plugin/treesitter.lua)
- Linter: Debounce 100ms to prevent excessive reruns (see plugin/linter.lua)

## Security Practices

### Nix
- Never hardcode passwords or API keys
- Use `lib.mkSecret` or flake input secrets for sensitive data
- Validate SSH keys are from trusted sources

### Lua
- Don't log sensitive data (API keys, tokens)
- Use `vim.secure.read()` for reading sensitive files
- Validate user input before passing to shell commands

## Compatibility

### Minimum Versions
- NixOS: 25.11
- Darwin: 6
- Home Manager: 26.05
- Neovim: Nightly (latest stable from master)

### Platform-Specific Code

```lua
-- Example: Platform detection in Lua
local is_darwin = vim.fn.has("mac") == 1
local is_linux = vim.fn.has("unix") == 1 and vim.fn.has("mac") == 0

if is_darwin then
  -- macOS-specific config
elseif is_linux then
  -- Linux-specific config
end
```

```nix
# Example: Platform detection in Nix
{ pkgs, lib, ... }:
{
  config = lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isDarwin {
      # macOS-specific config
    })
    (lib.mkIf pkgs.stdenv.isLinux {
      # Linux-specific config
    })
  ];
}
```

## Review Checklist

Before committing changes:

- [ ] Code follows naming conventions (kebab-case for files, camelCase for Nix vars, snake_case for Lua)
- [ ] Indentation: 2 spaces (Nix and Lua)
- [ ] Line length: 80 columns (enforced by stylua)
- [ ] Comments explain "why", not "what"
- [ ] No hardcoded secrets or sensitive data
- [ ] Flake syntax valid: `nix flake check`
- [ ] Lua formatted: `stylua config/nvim`
- [ ] Modules follow standard patterns (home-manager with mkIf, Lua with pcall)
- [ ] Commit message follows conventional commit format
- [ ] Related documentation (README, docs/) updated if applicable
