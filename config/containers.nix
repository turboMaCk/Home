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

  # Watchtower Container (Keeps your Docker containers updated)
  virtualisation.oci-containers.containers.watchtower = {
    image = "nickfedor/watchtower:latest";
    autoStart = true;
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock" # Allows Watchtower to talk to the Docker daemon
    ];
    environment = {
      WATCHTOWER_CLEANUP = "true"; # Removes old unused images after updating to save disk space
      WATCHTOWER_POLL_INTERVAL = "86400"; # Check for updates every 24 hours (in seconds)
      WATCHTOWER_NO_RESTART = "true";
    };
  };

  environment.systemPackages = with pkgs; [
  ];
}
