{ ... }:

{
  programs.lazygit = {
    enable = true;

    xdg.configFile."lazygit" = {
      source = ../config/lazygit;
      recursive = true;
    };
  };
}
