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

    # Plugins are managed by vim.pack from config/nvim/plugin/*.lua, not from
    # here: home-manager installs into pack/*/start, which Neovim sources
    # unconditionally and which would defeat every lazy-loading trigger.
  };

  xdg.configFile."nvim" = {
    source = ../config/nvim;
    recursive = true;
  };

  home.file.".editorconfig".source = ../config/.editorconfig;
}
