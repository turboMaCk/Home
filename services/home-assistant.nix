{ pkgs, lib, ... }:
let
  volume-name = "home-assistant";
  config = pkgs.writeTextFile {
    name = "configuration.yaml";
    text = ''
      http:
        use_x_forwarded_for: true
        trusted_proxies:
          - 127.0.0.1
          - ::1

      # Loads default set of integrations. Do not remove.
      default_config:
    '';
  };
in {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.dbus.enable = true;

  system.activationScripts.configureHomeAssistant = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/containers/storage/volumes/${volume-name}/_data
    cp -f ${config} /var/lib/containers/storage/volumes/${volume-name}/_data/configuration.yaml
  '';

  virtualisation.oci-containers.containers.homeassistant = {
    autoStart = true;
    volumes = [
      "${volume-name}:/config"
      "/var/run/dbus:/run/dbus:ro"
    ];
    environment.TZ = "Europe/Prague";
    image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
    extraOptions = [
      "--device=/dev/ttyUSB0:/dev/ttyUSB0" # sky connect
      "--network=host" # Among other things this mitigates issues with binding bluetooth into the container
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      8123
    ];
  };
}
