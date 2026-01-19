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
    lazydocker
    lazysql
    superfile
    R
    cmake
    p7zip-rar
    pkg-config
    google-cloud-sdk
    typst
    poppler-utils
  ];

  jsTools = with pkgs; [
    volta
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
    # dotnet-sdk_9
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
    dockerfile-language-server
    docker-compose-language-service
    hadolint

    # HTML, CSS
    vscode-langservers-extracted

    # Go
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
    python314
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
    prettier
    eslint

    # Yaml
    yaml-language-server
    yamlfmt
    yamllint
  ];
in
{
  home.packages = basic ++ misc ++ jsTools ++ editorTools;
}
