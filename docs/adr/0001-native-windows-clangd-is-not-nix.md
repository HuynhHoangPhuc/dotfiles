# Native Windows clangd is not Nix

This flake builds Machines (darwin, macOS, NixOS, WSL) and provisions clangd there via Home Manager `clang-tools`. Native Windows runs the same Neovim Language config outside Nix: Mason clangd indexes, Visual Studio LLVM 20 formats and lints, and Unreal projects own the Compile database, Style file, and Check set. A Windows Machine was rejected because Nix does not own this host, and WSL clangd cannot consume MSVC / Unreal compile commands.

## Considered Options

- Treat Native Windows as a flake Machine and install clangd with Nix — not a supported target, and it would still not match VS `clang-cl`.
- Point WSL Neovim at a Windows Unreal tree — path translation and MSVC flags fail in practice.
- Use Rider or Visual Studio instead of Neovim — better Unreal IDEs, but not this repo's editor.
