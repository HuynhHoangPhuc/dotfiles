{
  pkgs,
  username,
  hmStateVersion,
  ...
}:
let
  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  home.stateVersion = hmStateVersion;
  home.username = username;
  home.homeDirectory = homeDirectory;

  programs.home-manager.enable = true;

  home.sessionVariables = {
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    PROJECTS = "${homeDirectory}/Developer";
    DOTFILES_WITH_FLAKE = "1";
  };

  home.activation.developer = ''
    mkdir -p ~/Developer
  '';

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
}
