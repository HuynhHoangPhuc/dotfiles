# Native Windows clangd is not Nix

This flake builds Machines (darwin, macOS, NixOS, WSL) and provisions clangd there via Home Manager `clang-tools`. Native Windows runs the same Neovim Language config outside Nix: Visual Studio clangd (same LLVM 20 drop as UBT `clang-cl`) indexes, that same LLVM formats and lints, and Unreal projects own the Compile database, Style file, and Check set. Mason clangd 22 was tried and rejected: it treats `_m_prefetch` as a builtin while UBT's `-resource-dir` still points at Clang 20 headers. A Windows Machine was rejected because Nix does not own this host, and WSL clangd cannot consume MSVC / Unreal compile commands.

## Considered Options

- Treat Native Windows as a flake Machine and install clangd with Nix — not a supported target, and it would still not match VS `clang-cl`.
- Point WSL Neovim at a Windows Unreal tree — path translation and MSVC flags fail in practice.
- Use Mason clangd as the Native Windows indexer — mismatches UBT's Clang 20 resource-dir (see `.scratch/m-prefetch-builtin/research.md`).
- Use Rider or Visual Studio instead of Neovim — better Unreal IDEs (ReSharper C++ / EDG), but not this repo's editor.
