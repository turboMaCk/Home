{ pkgs, lib, ... }:
let
  volume-name = "home-assistant";
  config = pkgs.writeTextFile {
    name = "configuration.yaml";
    text = ''
      # Loads default set of integrations. Do not remove.
      default_config:
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
    extraOptions = [
      "--device=/dev/ttyUSB0:/dev/ttyUSB0" # sky connect
      "--cap-add=NET_ADMIN,NET_RAW" # Allow watching dhcp packets
      "--network=host" # Among other things this mitigates issues with binding bluetooth into the container
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
