{ pkgs, lib, ... }:
{
  services.transmission = {
    enable = true;
    openFirewall = true;
    webHome = "${pkgs.flood-for-transmission}";
    settings = {
      rpc-bind-address = "0.0.0.0";
      rpc-port = 9091;
      rpc-whitelist = "127.0.0.1,*.*.*.*";
    };
  };
  networking.firewall.allowedTCPPorts = [ 9091 ];
  networking.firewall.allowedUDPPorts = [ 9091 ];

  services.sonarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/sonarr/";
  };

  services.bazarr = {
    enable = true;
    openFirewall = true;
  };
}
