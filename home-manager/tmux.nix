{
  pkgs,
  ...
}:

{
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ../config/tmux/tmux.conf;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
      catppuccin
    ];
    # catppuccin.enable = false;
  };
}
