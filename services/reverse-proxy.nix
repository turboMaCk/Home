{ pkgs, lib, ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "home.local" = {
        extraConfig = ''
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://0.0.0.0:8123";
          proxyWebsockets = true;
        };
      };

      "torrent.local" = {
        globalRedirect = "192.168.0.5:9091";
      };

      "sonarr.local" = {
        locations."/" = {
          proxyPass = "http://thinkcentre.local:8989";
          proxyWebsockets = true;
        };
      };

      "bazarr.local" = {
        locations."/" = {
          proxyPass = "http://thinkcentre.local:6767";
          proxyWebsockets = true;
        };
      };

      "jellyfin.local" = {
        extraConfig = ''
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://thinkcentre.local:8096";
          proxyWebsockets = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
