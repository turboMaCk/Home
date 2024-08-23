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
          proxyPass = "http://121.0.0.1:8123";
          proxyWebsockets = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
