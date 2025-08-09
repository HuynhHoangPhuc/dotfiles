# https://github.com/numtide/flake-utils/blob/11707dc2f618dd54ca8739b309ec4fc024de578b/lib.nix

{
  # The list of systems supported by nixpkgs and hydra
  defaultSystems ? [
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
    "x86_64-linux"
  ],
}:

let
  inherit defaultSystems;

  # Applies a merge operation accross systems.
  eachSystemOp =
    op: systems: f:
    builtins.foldl' (op f) { } (
      if !builtins ? currentSystem || builtins.elem builtins.currentSystem systems then
        systems
      else
        # Add the current system if the --impure flag is used.
        systems ++ [ builtins.currentSystem ]
    );

  eachSystem = eachSystemOp (
    # Merge outputs for each system.
    f: attrs: system:
    let
      ret = f system;
    in
    builtins.foldl' (
      attrs: key:
      attrs
      // {
        ${key} = (attrs.${key} or { }) // {
          ${system} = ret.${key};
        };
      }
    ) attrs (builtins.attrNames ret)
  );

  eachSystemPassThrough = eachSystemOp (
    f: attrs: system:
    attrs // (f system)
  );

  # eachSystem using defaultSystems
  eachDefaultSystem = eachSystem defaultSystems;

  # eachSystemPassThrough using defaultSystems
  eachDefaultSystemPassThrough = eachSystemPassThrough defaultSystems;

  utils = {
    inherit
      defaultSystems
      eachDefaultSystem
      eachDefaultSystemPassThrough
      eachSystem
      eachSystemPassThrough
      ;
  };
in
utils
