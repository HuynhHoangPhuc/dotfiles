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
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

    darwinRebuild = inputs.nixpkgs.lib.getExe inputs.nix-darwin.packages.${system}.darwin-rebuild;
    dotfiles-switch = pkgs.writeScriptBin "dot-switch" ''
      echo "> Running system switch  ..."
      if [[ "$#" -ge 1 ]]; then
        sudo ${darwinRebuild} switch --flake ".#$1"
      else
        sudo ${darwinRebuild} switch --flake .
      fi
      echo "> System switch was successful ✅"
      echo "> Refreshing zshrc..."
      ${pkgs.lib.getExe pkgs.zsh} -c "source ${homeDirectory}/.zshrc"
      echo "> zshrc was refreshed successfully ✅"
      echo "> Config was successfully applied 🚀"
    '';
  in
  {
    devShells.default = pkgs.mkShellNoCC {
      name = "dotfiles";
      packages = [
        dotfiles-switch
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
