{
  inputs,
  username,
  hmStateVersion,
  darwinStateVersion,
  nixOSStateVersion,
  caches,
  darwinSystems ? [
    "aarch64-darwin"
    "x86_64-darwin"
  ],
  linuxSystems ? [
    "aarch64-linux"
    "x86_64-linux"
  ],
}:

let
  supportedSystems = darwinSystems ++ linuxSystems;
  utils = import ./lib/utils.nix { };

  overlays.default = final: prev: {
    neovim-nightly = inputs.neovim-nightly.packages.${prev.system}.default;
  };

  mkSystem = import ./lib/mksystem.nix {
    overlays = [ overlays.default ];
    inherit inputs caches;
  };
in
utils.eachSystem supportedSystems (
  system:
  let
    pkgs = import inputs.nixpkgs {
      inherit system;
    };

    darwinRebuild = inputs.nix-darwin.packages.${system}.darwin-rebuild;
    dotfiles-rebuild = pkgs.writeScriptBin "dotfiles-rebuild" ''
      sudo ${darwinRebuild}/bin/darwin-rebuild switch --flake .
      echo "DONE"
    '';
  in
  {
    devShells.default = pkgs.mkShellNoCC {
      name = "dotfiles";
      packages = with pkgs; [
        dotfiles-rebuild
      ];
    };
  }
)

// utils.eachSystemPassThrough darwinSystems (system: {
  darwinConfigurations.darwin = mkSystem "darwin" {
    inherit system username hmStateVersion;
    stateVersion = darwinStateVersion;
    darwin = true;
  };

  darwinConfigurations.macbook-air = mkSystem "macbook-air" {
    inherit system username hmStateVersion;
    stateVersion = darwinStateVersion;
    darwin = true;
  };
})

// utils.eachSystemPassThrough linuxSystems (system: {
  nixosConfigurations.nixos = mkSystem "nixos" {
    inherit system username hmStateVersion;
    stateVersion = nixOSStateVersion;
  };

  nixosConfigurations.wsl = mkSystem "wsl" {
    inherit system username hmStateVersion;
    stateVersion = nixOSStateVersion;
    wsl = true;
  };
})
