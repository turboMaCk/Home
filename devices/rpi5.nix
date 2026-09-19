{ config, pkgs, lib, ... }: {

  # BOOT partition is small, lets save some space
  # TODO: resize partitions
  boot.initrd.compressor = "xz";
  boot.loader.grub.configurationLimit = 3;
  hardware.deviceTree.filter = "bcm2712-rpi-5-b.dtb";

  boot.loader.raspberry-pi = {
    enable = true;
    # Force 'kernel' bootloader to stop kernelboot-builder from creating nixos-kernels/
    bootloader = lib.mkForce "kernel";
  };

  # use mkpasswd to generate
  users.users.root.initialHashedPassword = "$y$j9T$Lw7/egljRSL/9DO3sMMRK/$73H5fT5IYvXoASAgDTGwq5nTOuP5hrkK5c0VEq0RmF5";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/boot/firmware/nixos" = {
      device = "/nix/boot_staging";
      fsType = "none";
      options = [ "bind" ];
      neededForBoot = true;
    };
  };

  networking = {
    hostName = "rpi5";
    useDHCP = false;
    interfaces = {
      wlan0.useDHCP = true;
      eth0.useDHCP = true;
    };
  };

  documentation.nixos.enable = false;

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";

  # boot.tmp.cleanOnBoot = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should11
  system.stateVersion = "26.05"; # Did you read the comment?
}
