{
  pkgs,
  ...
}:

{
  programs.bat = {
    enable = true;

    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      batgrep
      batwatch
    ];
  };

  xdg.configFile."bat" = {
    source = ../config/bat;
    recursive = true;
  };
}
