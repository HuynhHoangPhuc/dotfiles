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
      "goland"
      "visual-studio-code"
      "docker-desktop"
      "scroll-reverser"
      "zalo"
      "microsoft-excel"
      "microsoft-word"
      "microsoft-powerpoint"
      "google-drive"
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };
}
