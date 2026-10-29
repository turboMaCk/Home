
{ config, pkgs, .. }:
{
  services.valutwarden = {
    enable = true;
    domain = "http://valutwarden.lan";
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
  };
}
