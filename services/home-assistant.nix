{ pkgs, lib, ... }:
let
  mosquitto-config = pkgs.writeTextFile {
    name = "mosquitto.conf";
    text = ''
      listener 1883
      allow_anonymous true
    '';
  };

  z2m-config = pkgs.writeTextFile {
    name = "z2m-configuration.yaml";
    text = ''
      homeassistant: true

      mqtt:
        base_topic: zigbee2mqtt
        server: 'mqtt://127.0.0.1:1883'

      serial:
        port: /dev/ttyUSB0
        adapter: ember

      frontend:
        port: 8080

      advanced:
        log_level: info
        log_output:
          - console
    '';
  };

in {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.dbus.enable = true;

  virtualisation.oci-containers.containers.homeassistant = {
    autoStart = true;
    image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
    extraOptions = [
      "--network=host" # Among other things this mitigates issues with binding bluetooth into the container
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
    ];
    volumes = [
      "home-assistant:/config"
      "/var/run/dbus:/run/dbus:ro"
    ];
    environment.TZ = "Europe/Prague";
  };

  virtualisation.oci-containers.containers.matter-server = {
    autoStart = true;
    image = "ghcr.io/home-assistant-libs/python-matter-server:stable";
    extraOptions = [
      "--network=host"
      "--security-opt=apparmor=unconfined"
    ];
    volumes = [
      "matter-server-data:/data"
      "/var/run/dbus:/run/dbus:ro"
    ];
    environment.TZ = "Europe/Prague";
  };

  virtualisation.oci-containers.containers.mosquitto = {
    autoStart = true;
    image = "eclipse-mosquitto:latest";
    extraOptions = [
      "--network=host"
    ];
    volumes = [
      "mosquitto-data:/mosquitto/data"
      "mosquitto-config:/mosquitto/config"
      "${mosquitto-config}:/mosquitto/config/mosquitto.conf"
    ];
    environment.TZ = "Europe/Prague";
  };

  system.activationScripts.configureZigbee2MQTT = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/docker/volumes/zigbee2mqtt-data/_data
    cp -n ${z2m-config} /var/lib/docker/volumes/zigbee2mqtt-data/_data/configuration.yaml
  '';

  virtualisation.oci-containers.containers.zigbee2mqtt = {
    autoStart = true;
    image = "ghcr.io/koenkk/zigbee2mqtt:latest";
    extraOptions = [
      "--device=/dev/ttyUSB0:/dev/ttyUSB0" # SkyConnect
      "--network=host"
    ];
    volumes = [
      "zigbee2mqtt-data:/app/data"
      "/run/udev:/run/udev:ro"
    ];
    environment.TZ = "Europe/Prague";
  };

  networking.enableIPv6 = true;
  networking.firewall = {
    allowedTCPPorts = [ 8123 5540 1883 8080 ];
    allowedUDPPorts = [ 5353 5540 ];
  };
}
