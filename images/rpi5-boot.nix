{ pkgs, lib, ... }: {
  # bcm2711 for rpi 3, 3+, 4, zero 2 w
  # bcm2712 for rpi 5
  # See the docs at:
  # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
  raspberry-pi-nix.board = "bcm2712";

  # use mkpasswd to generate
  users.users.root.initialHashedPassword = "$y$j9T$Lw7/egljRSL/9DO3sMMRK/$73H5fT5IYvXoASAgDTGwq5nTOuP5hrkK5c0VEq0RmF5";

  networking = {
    hostName = "rpi5-bootstrap";
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
}
