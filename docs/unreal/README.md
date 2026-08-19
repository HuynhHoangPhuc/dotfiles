# Unreal C++ Recipe

Copy the templates next to the `.uproject`, generate a Compile database, gitignore the generated files. Neovim's Language config does the rest.

On Native Windows, Visual Studio clangd (same LLVM drop as `clang-cl`) indexes and query-drives `clang-cl`. clang-format and clang-tidy are that same LLVM 20. Do not Mason-install those two, and do not strip UBT's `-resource-dir`. Nix Machines keep Home Manager `clang-tools`; Native Windows is not a Machine.

## Per-project files

Copy from `docs/unreal/templates/` into the Unreal project root:

| File | Role |
|---|---|
| `.clangd` | Header insertion off. Index in the background. Compile database at `.` |
| `.clang-format` | TensorWorks / Epic-style tabs. MIT; see `TENSORWORKS-LICENSE.md` |
| `.clang-tidy` | Analyzer + trimmed `bugprone-*`. `HeaderFilterRegex` is `Source/` |

On-save format and nvim-lint run only under `Source/`, or under a `Plugins/` tree that owns its own Style file or Check set. Engine, `Intermediate/`, `Saved/`, and `ThirdParty/` are skipped.

## Compile database

Build the Editor target once so UHT headers exist. Then, from the Engine's `Build.bat` directory:

```
Build.bat GameEditor Win64 Development -mode=GenerateClangDatabase -project="C:\absolute\path\Game.uproject" -game -engine
```

Replace `GameEditor` and the `.uproject` path. UBT writes `compile_commands.json` at the **Engine root** (`C:\Program Files\Epic Games\UE_<ver>\`). Copy that file onto the project root. Do not rewrite paths by hand.

Regenerate only after adding or removing a module or C++ plugin, changing a `.Build.cs`, moving the project, or switching Engine version. Not when opening Neovim or editing an existing file.

Add `-NoExecCodeGenActions` only when generated headers from a prior editor/build are already present.

## Gitignore (in the Unreal project)

```
compile_commands.json
.cache/
```

## After copy

Restart clangd (`:LspRestart`) in a `Source/` file. The first Engine-wide index is large; that is required to follow symbols into Engine headers.
