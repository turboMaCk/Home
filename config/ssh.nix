{ pkgs, lib, ...}:
{
  users.users.root.openssh.authorizedKeys.keys = [
    # Thinkpad
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6WwR81YfRFoqS/FpH3GE5F+HQylrTuHhev/mclzPj8 marek@nixos"
    # Desktop
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1wEkx/OhHXDIPF6evmgTvHG0+0iDA8fjQUvmhC9kwR marek.faj@gmail.com"
  ];

  services.sshd.enable = true;
}
