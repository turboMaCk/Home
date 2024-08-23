{ pkgs, lib, ... }:
let
  config = pkgs.writeTextFile {
    name = "config.yaml";
    text = ''
      http:
        use_x_forwarded_for: true
        trusted_proxies: 127.0.0.1
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


  virtualisation.podman = {
    enable = true;
    dockerCompat = true;

    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";

    containers.homeassistant = {
      autoStart = true;
      volumes = [
        "home-assistant:/config"
        "/var/run/dbus:/run/dbus:ro"
      ];
      environment.TZ = "Europe/Prague";
      image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
      ports = [ "121:0.0.1:8123:8123" ];
      extraOptions = [ 
        "--device=/dev/ttyUSB0:/dev/ttyUSB0" # sky connect
        "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE" # Allow watching dhcp packets
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
  ];

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

  #networking.firewall.allowedTCPPorts = [ 8123 ];
}
