{ pkgs, lib, ... }: {
  # This is PI 5
  raspberry-pi-nix.board = "bcm2712";

  # use mkpasswd to generate
  users.users.root.initialHashedPassword = "$y$j9T$Lw7/egljRSL/9DO3sMMRK/$73H5fT5IYvXoASAgDTGwq5nTOuP5hrkK5c0VEq0RmF5";

  networking = {
    hostName = "rpi5";
    useDHCP = false;
    interfaces = {
      wlan0.useDHCP = true;
      eth0.useDHCP = true;
    };
  };

  hardware = {
    bluetooth.enable = true;
    raspberry-pi = {
      config = {
        all = {
          base-dt-params = {
            # enable autoprobing of bluetooth driver
            # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
            krnbt = {
              enable = true;
              value = "on";
            };
          };
        };
      };
    };
  };

  documentation.nixos.enable = false;

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";

  boot.tmp.cleanOnBoot = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.05"; # Did you read the comment?
}
