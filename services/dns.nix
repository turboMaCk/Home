{ pkgs, lib, ... }: {
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = "192.168.0.4:53";
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query" # Cloudflare's DNS over HTTPS
      ];

      # For initial resolutions
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };

      customDNS = {
        customTTL = "5m";

        mapping = {
          # Network controller
          "net.lan" = "192.168.0.2";

          # rpi
          "home.lan" = "192.168.0.4";
          "zigbee2mqtt.lan" = "192.168.0.4";

          # Nas
          "nas.lan" = "192.168.0.23";

          # Traefik on nas
          "music.lan" = "192.168.0.250";
          "torrent.lan" = "192.168.0.250";
          "jellyfin.lan" = "192.168.0.250";
          "plex.lan" = "192.168.0.250";
          "speed.lan" = "192.168.0.250";
          "traefik.lan" = "192.168.0.250";
        };
      };

      blocking = {
        allowlists = {
          ads = [
            ''
              logs.us-east-1.amazonaws.com
              /^.*\.amazonaws\.com$/
            ''
          ];
          abuse = [
            ''
              logs.us-east-1.amazonaws.com
              /^.*\.amazonaws\.com$/
            ''
          ];
          malware = [
            ''
              logs.us-east-1.amazonaws.com
              /^.*\.amazonaws\.com$/
            ''
          ];
          phishing = [
            ''
              logs.us-east-1.amazonaws.com
              /^.*\.amazonaws\.com$/
            ''
          ];
          ransomware = [
            ''
              logs.us-east-1.amazonaws.com
              /^.*\.amazonaws\.com$/
            ''
          ];
          scam = [
            ''
              logs.us-east-1.amazonaws.com
              /^.*\.amazonaws\.com$/
            ''
          ];
          tracking = [
            ''
              logs.us-east-1.amazonaws.com
              /^.*\.amazonaws\.com$/
            ''
          ];
        };
        denylists = {
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://raw.githubusercontent.com/blocklistproject/Lists/master/ads.txt"
          ];
          abuse = [
            "https://raw.githubusercontent.com/blocklistproject/Lists/master/abuse.txt"
          ];
          malware = [
            "https://raw.githubusercontent.com/blocklistproject/Lists/master/malware.txt"
          ];
          phishing = [
            "https://raw.githubusercontent.com/blocklistproject/Lists/master/phishing.txt"
          ];
          ransomware = [
            "https://raw.githubusercontent.com/blocklistproject/Lists/master/ransomware.txt"
          ];
          scam = [
            "https://raw.githubusercontent.com/blocklistproject/Lists/master/scam.txt"
          ];
          tracking = [
            "https://raw.githubusercontent.com/blocklistproject/Lists/master/tracking.txt"
          ];
        };

        # Configure groups
        clientGroupsBlock = {
          default = [
            "ads" "malware" "phishing" "ransomware" "scam" "tracking" "abuse"
          ];
        };
      };

      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
