{
  lib,
  pkgs,
  username,
  ...
}:

let

  homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  programs.zsh = {
    enable = true;

    autocd = false;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    dotDir = homeDirectory;
    initContent = lib.mkOrder 1500 (builtins.readFile ../config/zsh/.zshrc);
  };
}
