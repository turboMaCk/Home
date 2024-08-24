{ pkgs, lib, ... }:
let
  volume-name = "home-assistant";
  config = pkgs.writeTextFile {
    name = "configuration.yaml";
    text = ''
      http:
        use_x_forwarded_for: true
        trusted_proxies:
          - 10.88.0.1 # podman gateway

      # Loads default set of integrations. Do not remove.
      default_config:

      # Load frontend themes from the themes folder
      frontend:
        themes: !include_dir_merge_named themes

      automation: !include automations.yaml
      script: !include scripts.yaml
      scene: !include scenes.yaml
    '';
  };
in {
  # As of Home Assistant 2023.12.0 many components started depending on the matter integration.
  # It unfortunately still relies on OpenSSL 1.1, which has gone end of life in 2023/09.
  # For home-assistant deployments to work after this release
  # you most likely need to allow this insecure dependency in our system configuration.
  #nixpkgs.config.permittedInsecurePackages = [
    #"openssl-1.1.1w"
  #];

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
    ports = [ "8123:8123" ];
    extraOptions = [
      "--device=/dev/ttyUSB0:/dev/ttyUSB0" # sky connect
      "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE" # Allow watching dhcp packets
    ];
  };

  # Declarative configuration
  # Not using for now
  #services.home-assistant = {
    #enable = true;
    #extraComponents = [
      ## Components required to complete the onboarding
      #"esphome"
      #"met"
      #"radio_browser"
      #"homeassistant_sky_connect"
    #];
    #config = {
      ## Includes dependencies for a basic setup
      ## https://www.home-assistant.io/integrations/default_config/
      #default_config = {};
    #};
  #};
}
