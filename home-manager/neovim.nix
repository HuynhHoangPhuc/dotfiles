{
  pkgs,
  ...
}:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;

    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      nvim-colorizer-lua
      nvim-web-devicons

      oil-nvim
      nvim-tree-lua
      mini-files

      fzf-lua

      # copilot-vim

      friendly-snippets
      blink-cmp
      nvim-autopairs
      nvim-ts-autotag
      nvim-surround

      (pkgs.vimPlugins.nvim-treesitter.withPlugins (
        plugins: with plugins; [
          arduino
          astro
          awk
          bash
          cpp
          css
          csv
          diff
          dockerfile
          fish
          git_config
          git_rebase
          gitattributes
          gitcommit
          gitignore
          go
          gomod
          gosum
          gowork
          graphql
          hcl
          html
          http
          http
          ini
          javascript
          jq
          json
          lua
          make
          markdown
          markdown_inline
          mermaid
          nix
          python
          query
          regex
          ruby
          rust
          scss
          sql
          ssh_config
          templ
          terraform
          toml
          typescript
          tsx
          vhs
          vim
          vimdoc
          yaml
          zig
        ]
      ))
      nvim-treesitter-textobjects
      nvim-treesitter-context
      nvim-treesitter-endwise

      nvim-lspconfig
      conform-nvim
      nvim-lint
      clangd_extensions-nvim
      omnisharp-extended-lsp-nvim

      indent-blankline-nvim
      gitsigns-nvim
    ];
  };

  xdg.configFile."nvim" = {
    source = ../config/nvim;
    recursive = true;
  };

  home.file.".editorconfig".source = ../config/.editorconfig;
}
