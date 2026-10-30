{ config, pkgs, ... }:
{
  # Can't use native service because of build fauilures of web client on RPI5 (likely page size alignment issue)
  virtualisation.oci-containers.containers.vaultwarden = {
    image = "vaultwarden/server:latest";
    autoStart = true;
    ports = [ "8222:80" ];
    volumes = [
      "/var/lib/vaultwarden:/data"
    ];
    environment = {
      SIGNUPS_ALLOWED = "true"; # Set to true initially if you need to register an account
      DOMAIN = "http://vaultwarden.lan"; # Your actual domain
    };
  };
}
