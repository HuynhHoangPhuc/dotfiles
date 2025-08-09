{
  pkgs,
  ...
}:

{
  nix = {
    package = pkgs.nixVersions.latest;
    # extraOptions = ''
    #   experimental-features = nix-command flakes
    # '';
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      grub.device = "/dev/sda";
      systemd-boot = {
        enable = true;
        consoleMode = "0";
      };
    };
  };

  services = {
    flatpak = {
      enable = true;
    };

    snap = {
      enable = true;
    };
  };
}
