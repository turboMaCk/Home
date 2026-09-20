{ pkgs, lib, ... }:
{
  # podman for ARM compilation is too expensive
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "docker";
  };

  environment.systemPackages = with pkgs; [
  ];
}
