{ config, ... }:

{
  xdg.configFile."ghostty" = {
    source = ../config/ghostty;
    recursive = true;
  };
}
