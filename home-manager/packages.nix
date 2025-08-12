{
  pkgs,
  ...
}:

let
  basic = with pkgs; [
    fd
    ripgrep
  ];

  misc = with pkgs; [
    lazygit
    lazydocker
    lazysql
  ];

  editorTools = with pkgs; [
    # ** Treesitter **
    tree-sitter

    # AstroJS
    astro-language-server
    prettier

    # C/C++
    clang-tools
    vscode-extensions.vadimcn.vscode-lldb

    # C#
    dotnet-sdk_9
    omnisharp-roslyn
    csharpier

    # CMake
    neocmakelsp
    gersemi
    cmake-lint

    # Bash
    bash-language-server
    shfmt

    # Docker
    dockerfile-language-server-nodejs
    docker-compose-language-service
    hadolint

    # HTML, CSS
    vscode-langservers-extracted

    # Go
    go
    gopls
    gotools
    gofumpt
    golangci-lint
    delve

    # Helm
    helm-ls

    # Lua
    lua-language-server
    stylua

    # Nix
    nil
    nixfmt-rfc-style

    # Python
    python3Full
    uv
    pyright
    ruff

    # Scala
    metals

    # SQL
    sqlfluff

    # TailwindCSS
    tailwindcss-language-server

    # Terraform
    terraform-ls
    tflint

    # Toml
    taplo

    # Typescript
    vtsls
    biome

    # Yaml
    yaml-language-server
    yamlfmt
    yamllint
  ];
in
{
  home.packages = basic ++ misc ++ editorTools;
}
