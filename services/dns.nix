{ pkgs, lib, ... }: {
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = 53;
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
          # Adblocking
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://blocklistproject.github.io/Lists/adds.txt"
          ];
          abuse = [
            "https://https://blocklistproject.github.io/Lists/abuse.txt"
          ];
          malware = [
            "https://https://blocklistproject.github.io/Lists/malware.txt"
          ];
          phishing = [
            "https://https://blocklistproject.github.io/Lists/phishing.txt"
          ];
          ramsomware = [
            "https://https://blocklistproject.github.io/Lists/ramsomware.txt"
          ];
          scam = [
            "https://https://blocklistproject.github.io/Lists/scam.txt"
          ];
          tracking = [
            "https://https://blocklistproject.github.io/Lists/traking.txt"
          ];
        };

        # Configure groups
        clientGroupsBlock = {
          default = [ "ads" "malware" "phishing" "ramsomware" "scam" "tracking" ];
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
