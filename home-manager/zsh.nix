{
  lib,
  ...
}:

{
  programs.zsh = {
    enable = true;

    autocd = false;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    initContent = lib.mkOrder 1500 (builtins.readFile ../config/zsh/.zshrc);
  };
}
