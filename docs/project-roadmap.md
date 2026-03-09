# Project Roadmap

## Current State (Phase: Stable)

### Completed Features

**Core Infrastructure**
- Nix Flakes architecture with 11 pinned inputs
- mkSystem factory pattern for multi-platform configs
- 4 system configurations: darwin, macbook-air, nixos, wsl
- Home Manager module system with 18 modules
- Reproducible builds via flake.lock

**User Environment**
- Zsh shell with autocompletion + syntax highlighting
- Starship prompt configuration
- Ghostty terminal emulator setup
- 6 Nerd Fonts installed and available
- Direnv integration (auto-loads .env files)

**Development Tools**
- 115+ LSP/formatter/linter tools auto-installed
- Volta for Node.js version management
- Go environment (GOPATH=~/Developer/Go)
- Python + Pyright setup
- Git integration (LFS, global gitignore, nvim editor)

**Editor: Neovim**
- Nightly build from flake overlay
- 20+ plugins installed (native vim.pack)
- 44 Treesitter parsers
- 13 per-language LSP/formatter/linter configs
- FZF picker integration (C-p files, C-g grep, C-\ buffers)
- Mini.files explorer with dual-cache git status
- Blink.cmp for completion
- Gitsigns for git integration
- nvim-surround, nvim-autopairs, colorizer, indent guides

**Multiplexing & Git**
- Tmux with Catppuccin Mocha theme
- Vim-tmux-navigator integration
- LazyGit TUI
- GitHub CLI with 7 extensions
- Delta for syntax-highlighted diffs

**Theme & Visual Consistency**
- Catppuccin Mocha across Neovim, Tmux, Ghostty
- Pure black background (#000000) for OLED
- Consistent color palette across all apps

**Platform Support**
- macOS (generic + MacBook Air specific)
- NixOS (generic, targets aarch64/x86_64)
- WSL2 (with Windows interop)

**State Versions**
- Home Manager: 26.05
- Darwin: 6
- NixOS: 25.11
- Neovim: Nightly

### Known Limitations & TODOs

**Documentation**
- [ ] Installation script for new machines (currently manual clone + flake update)
- [ ] Troubleshooting guide for common issues
- [ ] Per-language quickstart guides (how to set up TypeScript project, Python venv, etc)
- [ ] Video tutorials for setup

**Neovim**
- [ ] Copilot is disabled (investigate integration)
- [ ] Helix editor as alternative (if motivated)
- [ ] Custom snippets library (currently using defaults)
- [ ] Debugging configuration (DAP integration)

**Testing & CI/CD**
- [ ] Automated flake validation in CI
- [ ] Test suite for system configs (darwin-rebuild dry-run in CI)
- [ ] Health check script (`nvim-health`, etc)
- [ ] Pre-commit hooks for Nix/Lua linting

**Additional Languages**
- [ ] Rust environment setup (rust-analyzer, cargo, clippy)
- [ ] Kotlin support (Kotlin Language Server)
- [ ] Swift support (Swift Language Server, only macOS)
- [ ] Ruby environment

**Developer Experience**
- [ ] Makefile or task runner (just, make) for common commands
- [ ] `dot-setup` script for new machines
- [ ] Per-project Nix dev shells (flake.nix in project repos)
- [ ] Nix flake templates for new projects

**macOS Specific**
- [ ] iTerm2 alternative to Ghostty
- [ ] Additional Homebrew apps (Raycast, Arc, Figma, etc)
- [ ] Karabiner-Elements for custom key remapping
- [ ] macOS system defaults optimization

**NixOS Specific**
- [ ] KDE/GNOME desktop environment config (currently headless)
- [ ] Additional display servers (X11 vs Wayland)
- [ ] NixOS-specific security hardening

**WSL2 Specific**
- [ ] Windows Terminal integration
- [ ] GUI app launchers (Windows native apps from WSL)
- [ ] File sharing optimization (/mnt performance)
- [ ] VSCode Remote WSL container config

## Proposed Phases

### Phase 1: Documentation & Developer Onboarding (Next Quarter)

**Goals:**
- Reduce time-to-productivity for new machines
- Create reference guides for all major components
- Establish contribution guidelines

**Tasks:**
- [x] Create project overview & PDR
- [x] Create codebase summary
- [x] Create code standards
- [x] Create system architecture docs
- [ ] Create installation guide (clone, flake update, rebuild steps)
- [ ] Create troubleshooting FAQ
- [ ] Create per-language quickstart guides
- [ ] Add contribution guidelines (commit format, testing, review)
- [ ] Create Makefile with common commands (make update, make validate, make format)

**Success Criteria:**
- New developer can set up environment in < 30 minutes
- All major components documented
- Clear examples for extending (adding packages, languages, tools)

### Phase 2: Testing & CI/CD (Month 2-3)

**Goals:**
- Prevent configuration regressions
- Enable confident changes
- Streamline development workflow

**Tasks:**
- [ ] Set up GitHub Actions to validate flake on each commit
- [ ] Add `nix flake check` to CI
- [ ] Add `darwin-rebuild switch --dry-run` for macOS configs
- [ ] Add `nixos-rebuild build` for NixOS configs
- [ ] Create health check script (verify packages installed, verify LSP accessible)
- [ ] Add Nix linting (nixfmt, statix)
- [ ] Add Lua linting (stylua, selene)
- [ ] Add pre-commit hooks for local validation

**Success Criteria:**
- All configs build successfully in CI
- Linting passes for Nix and Lua
- Breaking changes caught before merge

### Phase 3: Neovim Enhancements (Month 4-5)

**Goals:**
- Improve editor experience
- Add debugging support
- Expand language support

**Tasks:**
- [ ] Integrate DAP (debug adapter protocol) for TypeScript/Python/Go debugging
- [ ] Enable GitHub Copilot with proper keybindings
- [ ] Add custom Lua/TypeScript/Python snippet library
- [ ] Improve error handling & diagnostics display
- [ ] Add telescope alternative to FZF (if significant advantage)
- [ ] Consider Helix integration as alternative editor option
- [ ] Add AI-assisted coding features (if beneficial)

**Success Criteria:**
- Debugging workflow functional for 3+ languages
- Snippet insertion fast and intuitive
- Copilot working reliably (if enabled)

### Phase 4: Additional Languages & Frameworks (Month 6-7)

**Goals:**
- Support more development contexts
- Enable rapid project scaffolding

**Tasks:**
- [ ] Add Rust support (rust-analyzer, cargo, clippy, miri)
- [ ] Add Kotlin support (Kotlin Language Server)
- [ ] Add Swift support (Swift Language Server, macOS only)
- [ ] Add Ruby support (ruby-lsp, rubocop)
- [ ] Add Java support (jdtls, optional heavy)
- [ ] Create per-language dev shell templates
- [ ] Document multi-language project setup

**Success Criteria:**
- All listed languages configured and tested
- New project scaffolding < 2 minutes

### Phase 5: Enhanced Developer Experience (Month 8-9)

**Goals:**
- Streamline common workflows
- Reduce context switching
- Enable team collaboration

**Tasks:**
- [ ] Create `dot-setup` installation script (automated for new machines)
- [ ] Add `dot-` command wrappers (dot-update, dot-check, dot-format)
- [ ] Create project template repo (includes flake.nix, direnv)
- [ ] Add multi-workspace support (project switching)
- [ ] Implement shell functions for common git workflows
- [ ] Add environment switching (dev/staging/prod shells)
- [ ] Create team-shared configuration profiles

**Success Criteria:**
- Installation time < 10 minutes
- Common tasks accessible via `dot-*` commands
- Easy context switching between projects

### Phase 6: Platform-Specific Enhancements (Month 10-11)

**Goals:**
- Optimize for each platform's strengths
- Add platform-specific tools
- Improve performance per platform

**Tasks:**
- **macOS:**
  - [ ] Add Raycast alternative to Spotlight
  - [ ] Add Karabiner-Elements for key remapping
  - [ ] Add macOS system defaults optimization
  - [ ] Add Homebrew cask auto-update
  - [ ] Consider additional IDE bundles (Xcode tools)

- **NixOS:**
  - [ ] Add KDE/GNOME desktop environment option
  - [ ] Add X11 vs Wayland selection
  - [ ] Add security hardening profiles
  - [ ] Add encrypted root filesystem option
  - [ ] Add systemd user services template

- **WSL2:**
  - [ ] Windows Terminal integration config
  - [ ] WSL-native app launchers (Windows .exe from WSL)
  - [ ] Performance optimization for /mnt
  - [ ] Automated WSL2 update management
  - [ ] GPU access (if available)

**Success Criteria:**
- Each platform has 3+ platform-specific optimizations
- Performance optimizations measurable (startup time, rebuild time)
- Platform-specific features well-documented

### Phase 7: Advanced Features & Optimization (Month 12+)

**Goals:**
- Production-ready security & performance
- Advanced user features
- Enterprise/team deployment

**Tasks:**
- [ ] Implement sops-nix for encrypted secret management
- [ ] Add hardware-specific optimization profiles (laptop vs desktop vs server)
- [ ] Implement automatic backup/restore of user data
- [ ] Add cloud sync for dotfiles across machines
- [ ] Create flake-based development container configs
- [ ] Implement gradual rollout strategy (canary configs)
- [ ] Add telemetry/analytics (opt-in) for usage patterns
- [ ] Performance profiling & optimization
- [ ] Add arm64 Windows support (if WSL supports)

**Success Criteria:**
- Secrets management integrated
- Backup/restore working across platforms
- Cloud sync available
- Performance optimized for all platforms

## Dependency Tracking

### Phase 1 Blockers
- None (can proceed immediately)

### Phase 2 Blockers
- Phase 1 completion (documentation needed for CI insights)

### Phase 3 Blockers
- None (independent of Phases 1-2)

### Phase 4 Blockers
- None (independent, can start anytime)

### Phase 5 Blockers
- Phase 1 completion (installation docs needed)

### Phase 6 Blockers
- None (can start in parallel with others)

### Phase 7 Blockers
- Phase 1 completion (documentation)
- Phase 5 completion (dev tools maturity)

## Resource Allocation

**Estimated Effort per Phase:**
- Phase 1: 10-15 hours (documentation heavy)
- Phase 2: 8-12 hours (CI/CD setup)
- Phase 3: 15-20 hours (plugin integration, testing)
- Phase 4: 12-18 hours (language configs, testing)
- Phase 5: 10-15 hours (scripting, workflow optimization)
- Phase 6: 12-20 hours (platform-specific testing & tuning)
- Phase 7: 20-30 hours (advanced features, optimization)

**Total:** 87-130 hours over 12 months

## Success Metrics

### Phase 1
- [ ] New developer setup time < 30 minutes
- [ ] 100% documentation coverage of major components
- [ ] Contribution guidelines clear

### Phase 2
- [ ] 100% CI build success rate
- [ ] Zero flake lint warnings
- [ ] All configs validate in CI

### Phase 3
- [ ] Debugging functional for TypeScript, Python, Go
- [ ] Snippet insertion latency < 100ms
- [ ] Copilot response time < 2 seconds

### Phase 4
- [ ] All 5+ languages configured and tested
- [ ] LSP server for each language functional
- [ ] Formatter & linter verified for each language

### Phase 5
- [ ] Installation time < 10 minutes via `dot-setup`
- [ ] All `dot-*` commands working
- [ ] Project templates available

### Phase 6
- [ ] macOS rebuilds in < 2 minutes
- [ ] NixOS rebuilds in < 3 minutes
- [ ] WSL rebuilds in < 2 minutes
- [ ] Platform-specific features documented

### Phase 7
- [ ] Secrets encrypted via sops-nix
- [ ] Backup/restore tested across platforms
- [ ] Cloud sync tested
- [ ] Performance benchmarks recorded

## Maintenance Tasks (Ongoing)

- Update `flake.lock` monthly (security + new features)
- Review and update Home Manager state versions (quarterly)
- Test builds on new macOS/NixOS releases
- Security updates for dependencies (when available)
- Refactor & simplify architecture (as needed)
- Update documentation (as new features added)
- Community engagement (issue triage, discussions)

## Long-Term Vision (12+ Months)

**Aspirations:**
1. **Company-ready template:** Shareable flake for teams to fork and customize
2. **CI/CD integration:** Automated deployment to multiple machines
3. **Secrets management:** Sops-nix integration for encrypted config
4. **Cloud sync:** Dotfiles sync across personal devices
5. **Performance:** Deterministic rebuilds in < 30 seconds
6. **Security:** Zero-trust architecture for cloud environments
7. **Community:** Contributions from other Nix developers
8. **Package maintenance:** Maintain custom packages in nixpkgs-overlays

## Known Issues & Workarounds

| Issue | Impact | Workaround | Status |
|-------|--------|-----------|--------|
| Copilot disabled | Dev velocity | Manual API calls | Needs investigation |
| Treesitter slow on large files | Latency | Skip files > 100KB | Mitigated |
| Linter spam in noisy repos | Noise | 100ms debounce | Mitigated |
| WSL2 /mnt performance | I/O overhead | Native C: drive access | Documented |
| macOS Homebrew sync | Consistency | nix-homebrew | Integrated |

## Unresolved Questions

1. **Should Helix be supported alongside Neovim?** (Effort vs benefit trade-off)
2. **Is container/OCI support needed?** (Nix vs Docker)
3. **How to handle secrets at scale?** (sops-nix vs external vault)
4. **Should team configurations be templated?** (Generic vs use-case-specific)
5. **Is telemetry valuable?** (Privacy trade-off)
6. **How to coordinate across multiple machines?** (Manual git pull vs sync service)
