# Documentation Index

Welcome to the dotfiles documentation. This guide helps you navigate all available resources.

## Quick Navigation

### Getting Started
- **[README.md](../README.md)** — Project overview, quick start, supported systems
- **[Project Overview & PDR](./project-overview-pdr.md)** — Goals, architectural decisions, requirements

### Understanding the Codebase
- **[Codebase Summary](./codebase-summary.md)** — Directory structure, file purposes, module descriptions
- **[Code Standards](./code-standards.md)** — Nix & Lua conventions, formatting, modularization rules
- **[System Architecture](./system-architecture.md)** — Multi-platform design, data flow, technical details

### Planning & Development
- **[Project Roadmap](./project-roadmap.md)** — Current state, proposed phases, success metrics

## Documentation by Role

### For New Developers
1. Read [README.md](../README.md) — Get oriented
2. Follow Quick Start for your platform
3. Read [Codebase Summary](./codebase-summary.md) — Understand structure
4. Read [Code Standards](./code-standards.md) — Learn conventions before coding

### For Architects/Planners
1. Read [Project Overview & PDR](./project-overview-pdr.md) — Understand goals and decisions
2. Read [System Architecture](./system-architecture.md) — Deep technical understanding
3. Read [Project Roadmap](./project-roadmap.md) — See phases and priorities

### For Contributors
1. Read [Code Standards](./code-standards.md) — Conventions for Nix & Lua
2. Check [Project Roadmap](./project-roadmap.md) — Find issues to work on
3. Follow conventional commit format in Code Standards

### For Maintainers
1. Monitor [Project Roadmap](./project-roadmap.md) — Track progress
2. Keep [Codebase Summary](./codebase-summary.md) updated as files change
3. Update [Code Standards](./code-standards.md) if conventions evolve
4. Review [System Architecture](./system-architecture.md) during major refactors

## Documentation Structure

```
docs/
├── index.md                      # This file (navigation)
├── project-overview-pdr.md       # Goals, decisions, requirements (198 LOC)
├── codebase-summary.md           # File structure, modules (328 LOC)
├── code-standards.md             # Nix/Lua conventions (476 LOC)
├── system-architecture.md        # Technical design (561 LOC)
└── project-roadmap.md            # Phases, metrics (392 LOC)
```

## File Statistics

| Document | Lines | Purpose |
|----------|-------|---------|
| project-overview-pdr.md | 198 | Project goals, architectural decisions, PDR |
| codebase-summary.md | 328 | Directory structure, file descriptions |
| code-standards.md | 476 | Nix & Lua coding conventions |
| system-architecture.md | 561 | Multi-platform architecture, data flow |
| project-roadmap.md | 392 | Phases, success criteria, timeline |
| **TOTAL** | **1,955** | **All < 800 LOC per file** |

## Key Sections by Topic

### Nix Configuration
- [Codebase Summary: Home Manager Modules](./codebase-summary.md#key-files-explained) — Describes all 18 modules
- [Code Standards: Nix Conventions](./code-standards.md#nix-conventions) — Style guide and patterns
- [System Architecture: Configuration Composition](./system-architecture.md#configuration-composition) — How modules load

### Neovim Setup
- [Codebase Summary: Neovim Architecture](./codebase-summary.md#neovim-architecture) — Plugin structure, configs
- [System Architecture: Neovim Architecture](./system-architecture.md#neovim-architecture) — LSP/formatter/linter setup
- [Code Standards: Lua Conventions](./code-standards.md#lua-conventions) — Lua coding style

### Multi-Platform Support
- [System Architecture: Platform-Specific Architecture](./system-architecture.md#platform-specific-architecture) — macOS/NixOS/WSL2 design
- [Codebase Summary: Directory Structure](./codebase-summary.md#directory-structure-overview) — machines/ directory organization
- [Project Overview: Platform-Specific Design](./project-overview-pdr.md#platform-specific-design) — High-level platform differences

### Development Workflow
- [Codebase Summary: Development Workflow](./codebase-summary.md#development-workflow) — Edit → rebuild → verify → commit
- [Code Standards: Git & Version Control](./code-standards.md#git--version-control) — Commit conventions
- [System Architecture: Data Flow](./system-architecture.md#data-flow) — Build time vs activation time

### Extending the System
- [System Architecture: Evolution & Extensibility](./system-architecture.md#evolution--extensibility) — Adding machines, languages, modules
- [Project Roadmap: Proposed Phases](./project-roadmap.md#proposed-phases) — Future work and enhancements

## Common Tasks

### "How do I add a new language to Neovim?"
1. See [System Architecture: Adding New Languages](./system-architecture.md#adding-new-languages-to-neovim)
2. Follow [Code Standards: Lua Conventions](./code-standards.md#lua-conventions)
3. Check examples in [Codebase Summary: languages/](./codebase-summary.md#confignvimlualanguages)

### "How do I add a new package to the system?"
1. See [System Architecture: Adding New Global Package](./system-architecture.md#adding-new-global-package)
2. Edit `home-manager/packages.nix`
3. Run rebuild: `darwin-rebuild switch --flake .`

### "What are the code style conventions?"
1. [Code Standards: Nix Conventions](./code-standards.md#nix-conventions) — For Nix code
2. [Code Standards: Lua Conventions](./code-standards.md#lua-conventions) — For Lua code
3. [Code Standards: Review Checklist](./code-standards.md#review-checklist) — Before committing

### "How do I understand the architecture?"
1. [System Architecture: Overview](./system-architecture.md#overview) — 4-layer model
2. [System Architecture: Nix Flake Architecture](./system-architecture.md#nix-flake-architecture) — Inputs and outputs
3. [System Architecture: mkSystem Factory Pattern](./system-architecture.md#mksystem-factory-pattern) — Core design

### "What's the roadmap?"
1. [Project Roadmap: Current State](./project-roadmap.md#current-state-phase-stable) — Completed features
2. [Project Roadmap: Proposed Phases](./project-roadmap.md#proposed-phases) — Next 12 months
3. [Project Roadmap: Success Metrics](./project-roadmap.md#success-metrics) — Phase-by-phase criteria

## Links & References

- **Main README**: [../README.md](../README.md)
- **Repository Root**: [../](../)
- **Machines Directory**: [../machines/](../machines/)
- **Home Manager**: [../home-manager/](../home-manager/)
- **Neovim Config**: [../config/nvim/](../config/nvim/)
- **Library Utilities**: [../lib/](../lib/)

## Document Maintenance

**Last Updated:** 2026-03-09
**Maintainer:** Documentation team
**Review Cycle:** Quarterly or when major changes occur

### Update Guidelines
- Add new documents when introducing new subsystems (e.g., container support, team configs)
- Keep each document under 800 lines for readability
- Update Index when adding/removing files
- Ensure all relative links remain valid
- Include line counts in statistics table

---

**Need Help?** Start with the role-specific path that matches your background above.
