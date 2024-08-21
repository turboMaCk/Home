{ pkgs, lib, ... }: {
  # bcm2711 for rpi 3, 3+, 4, zero 2 w
  # bcm2712 for rpi 5
  # See the docs at:
  # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
  raspberry-pi-nix.board = "bcm2712";
  time.timeZone = "Europe/Prague";

  # use mkpasswd to generate
  users.users.root.initialHashedPassword = "$y$j9T$Lw7/egljRSL/9DO3sMMRK/$73H5fT5IYvXoASAgDTGwq5nTOuP5hrkK5c0VEq0RmF5";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgBVB966ZfrwwOloWlOHeBqIbVFpDxj+bIerQy0TgKNpOZbG8qXaP6zkwyCvY0B8Zqjrvj8sDtcKZkX5YG1qfsunmdnCBvZG3oXWjYzaptpJPnhDQz3yWbShCwzlQ0n/YvkpU5zegYpfYUw5dCvI1FV+OCnjsWqrRTX32XGSsvGTPgfFUYOUZz9V5Qn2gh9/eqPCK4eNM9+gJyk+9izXJLHv3Ksyaeul4O2XHrtiDrZ5BifrENjePKP1cqAqQWX5RNZk+LXLUU1QllSodtMqyH0jA3xJndLTKCx2Rx33XzqNNlmIi/h002CXZJciwR+BJGhmw2nTGoRQ3Q7FIbvBkh marek.faj@gmail.com"
  ];

  # Enable flakes
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
   '';

    settings.sandbox = true;
  };

  networking = {
    hostName = "basic-example";
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

  services.sshd.enable = true;

  environment.systemPackages = with pkgs; [ vim git ];
}
