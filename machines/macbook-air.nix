{
  config,
  username,
  ...
}:

{
  imports = [
    ./darwin.nix
  ];

  system.primaryUser = username;

  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true; # Disable quarantine for casks
    global.brewfile = true; # Use a global Brewfile
    taps = builtins.attrNames config.nix-homebrew.taps;
    casks = [
      "brave-browser"
      "ghostty"
      "clion"
      "pycharm"
      "visual-studio-code"
      "docker-desktop"
      "beekeeper-studio"
      "scroll-reverser"
      "zalo"
      "microsoft-excel"
      "microsoft-word"
      "microsoft-powerpoint"
      "google-drive"
      "wireshark-app"
      "orbstack"
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
