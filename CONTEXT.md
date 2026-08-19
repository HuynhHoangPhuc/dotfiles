# Dotfiles

Personal, declarative environment for the machines this repo can build, plus the Neovim config that is also used on Native Windows.

## Language

**Machine**:
A named flake-built system this repo can switch: darwin, macbook-air, nixos, and wsl.
_Avoid_: host, box, platform (when you mean a flake config)

**Native Windows**:
The Windows 11 host running Neovim outside Nix. Not a Machine.
_Avoid_: Windows machine (ambiguous with Machine)

**Language config**:
A per-language Neovim module that declares that language's language server, formatter, and linter.
_Avoid_: LSP config, language server config

**Compile database**:
The `compile_commands.json` a C++ tree must provide for clangd. An Unreal project owns one next to its `.uproject`; it is not part of a Language config.
_Avoid_: compilation database, compile_flags

**Style file**:
A `.clang-format` owned by a C++ tree. The Language config runs clang-format; it does not own the style.
_Avoid_: format config, clang-format config

**Check set**:
A `.clang-tidy` owned by a C++ tree. The Language config runs clang-tidy; it does not own the checks.
_Avoid_: tidy config, lint rules

**Recipe**:
The reusable Unreal kit this repo keeps: Language config knobs, copy-paste templates, and the generate doc.
_Avoid_: guide, setup, tutorial
