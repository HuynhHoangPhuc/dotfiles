{
  pkgs,
  ...
}:

{
  programs.zsh = {
    enable = true;

    autocd = false;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
  };
}
