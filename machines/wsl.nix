{
  pkgs,
  username,
  ...
}:

{
  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = username;
    startMenuLaunchers = true;
  };

  nix = {
    package = pkgs.nixUnstable;
    # extraOptions = ''
    #   experimental-features = nix-command flakes
    # '';
  };
}
