{
  pkgs,
  ...
}:

{
  programs.gh = {
    enable = true;

    extensions = with pkgs; [
      gh-actions-cache
      gh-cal
      gh-dash
      gh-eco
      gh-markdown-preview
      gh-ost
      gh-screensaver
    ];
    gitCredentialHelper = {
      enable = true;
      hosts = [ "https://github.com" ];
    };
    settings = {
      editor = "nvim";
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
