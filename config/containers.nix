{ pkgs, lib, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    autoUpdate.enable = true;

    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
  };

  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
  ];
}
