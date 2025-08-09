{
  lib,
  ...
}:

{
  programs.starship = {
    enable = true;

    enableZshIntegration = true;
  };

  xdg.configFile."starship.toml".source = lib.mkForce ../config/starship/starship.toml;
}
