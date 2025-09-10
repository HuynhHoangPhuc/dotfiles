# https://github.com/mitchellh/nixos-config/blob/8114a05d1662015f6be4e35b758f0e966c1f4670/lib/mksystem.nix

{
  inputs,
  overlays,
  caches,
}:

name:
{
  system,
  username,
  stateVersion,
  hmStateVersion,
  darwin ? false,
  wsl ? false,
}:

let
  isWSL = wsl;
  isLinux = !darwin && !isWSL;
  isDarwin = darwin;

  machineConfig = ../machines/${name}.nix;
  hmConfig = ../home-manager;

  systemFunc =
    if isDarwin then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;

  home-manager =
    if isDarwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;

  pkgs = import inputs.nixpkgs {
    inherit system;
  };

in
systemFunc {
  inherit system;

  specialArgs = {
    inherit
      username
      inputs
      ;
  };

  modules = [
    { system.stateVersion = stateVersion; }

    { nixpkgs.overlays = overlays; }

    { nixpkgs.config.allowUnfree = true; }

    {
      fonts.packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.recursive-mono
        nerd-fonts.monaspace
        nerd-fonts.martian-mono
        nerd-fonts.code-new-roman
        nerd-fonts.jetbrains-mono
      ];
    }

    {
      environment = {
        shells = with pkgs; [
          bash
          zsh
        ];
        systemPackages = [ pkgs.coreutils ];
        systemPath = [
          # "/usr/local/bin"
        ];
        pathsToLink = [ "/Applications" ];
      };
    }

    {
      nix = {
        enable = false;
        # extraOptions = ''
        #   experimental-features = nix-command flakes
        # '';
        # enable = true;
        # gc = {
        #   automatic = true; # Enable automatic garbage collection
        #   interval = [
        #     {
        #       Hour = 4;
        #       Minute = 30;
        #       Weekday = 2;
        #     }
        #   ]; # Garbage collect every Tuesday at 4:30 AM
        #   options = "--delete-older-than 7d"; # Delete old garbage
        # };
        # optimise.automatic = true; # Enable automatic garbage collection
        settings = rec {
          cores = 0;
          substituters = with caches; [
            nixos-org.cache
            nix-community.cache
          ];
          trusted-public-keys = with caches; [
            nixos-org.publicKey
            nix-community.publicKey
          ];
          trusted-substituters = substituters;
          trusted-users = [
            "root"
            username
          ];
        };
      };
    }

    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else { })

    (if isLinux then inputs.nix-snapd.nixosModules.default else { })

    (if isDarwin then inputs.nix-homebrew.darwinModules.nix-homebrew else { })

    (
      if isDarwin then
        {
          nix-homebrew = {
            enable = true;
            user = username;
            autoMigrate = true;
            taps = {
              "homebrew/homebrew-core" = inputs.homebrew-core;
              "homebrew/homebrew-cask" = inputs.homebrew-cask;
              "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
            };
            mutableTaps = false;
          };
        }
      else
        { }
    )

    machineConfig

    home-manager.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = {
        imports = import hmConfig;
      };
      home-manager.extraSpecialArgs = {
        inherit username hmStateVersion;
      };
      home-manager.backupFileExtension = "backup";
    }
  ];
}
