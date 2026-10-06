{ pkgs, lib, ... }: {
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = "192.168.0.4:53";
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query" # Cloudflare's DNS over HTTPS
      ];

      # For initial resolutions
      # Cloudflare again
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };

      customDNS = {
        customTTL = "5m";

        mapping = {
          "net.local" = "192.168.0.2";
          "home.local" = "192.168.0.4";
          "thinkcentre.local" = "192.168.0.5";
          "torrent.local" = "192.168.0.4";
          "jellyfin.local" = "192.168.0.4";
        };
      };

      blocking = {
        blackLists = {
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
          default = [ "ads" "malware" "phishing" "ransomware" "scam" "tracking" "abuse" ];
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
