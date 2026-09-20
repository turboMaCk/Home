{ pkgs, lib, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;

    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
  };

  environment.systemPackages = with pkgs; [
    podman-tui # status of containers in the terminal
  ];
}
