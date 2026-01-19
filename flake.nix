{
  description = "My dotfiles config";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-snapd = {
      url = "github:nix-community/nix-snapd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs =
    inputs:
    let
      env = if builtins.pathExists ./env.nix then import ./env.nix else { };
      hmStateVersion = env.hmStateVersion or "26.05";
      darwinStateVersion = env.darwinStateVersion or 6;
      nixOSStateVersion = env.nixOSStateVersion or "25.11";
      username = env.username or "phuc";

      caches = {
        nixos-org = {
          cache = "https://cache.nixos.org";
          publicKey = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
        };
        nix-community = {
          cache = "https://nix-community.cachix.org";
          publicKey = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
        };
      };

      configurations = import ./configuration.nix {
        inherit
          inputs
          username
          hmStateVersion
          darwinStateVersion
          nixOSStateVersion
          caches
          ;
      };
    in
    configurations;
}
