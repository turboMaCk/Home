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
  users.users.root.initialHashedPassword = "$6$bCVhxN/V3xpX8m7H$5bcuFMx1VEtE6w9Y3zorg8/DKNB/vHL6qmkCuMiO0GR4ARUEdM8KGeq/Px8hkJR/tjIGx5HLcFHe0ktI8NJVD0";

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [ "subvol=@root" "compress=zstd" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [ "subvol=@log" "compress=zstd" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
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
