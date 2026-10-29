{ config, pkgs, ... }:
{
  services.vaultwarden = {
    enable = true;
    domain = "http://vaultwarden.lan";
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
  };
}
