{ pkgs, lib, ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "home.lan" = {
        extraConfig = ''
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:8123";
          proxyWebsockets = true;
        };
      };

      "zigbee2mqtt.lan" = {
        extraConfig = ''
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
