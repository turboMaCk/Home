{
  description = "turbo_MaCk's home infrastructure";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, nixpkgs, raspberry-pi-nix, deploy-rs }:
    let
      inherit (nixpkgs.lib) nixosSystem;
      rpi5-boot = import ./images/rpi5-boot.nix;
    in {
      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      # System configurations
      nixosConfigurations = {
        # Basic image just for botting NixOS on rpi5
        rpi5-boot = nixosSystem {
          system = "aarch64-linux";
          modules = [ raspberry-pi-nix.nixosModules.raspberry-pi rpi5-boot ];
        };

        rpi5 = nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./devices/rpi5.nix
            raspberry-pi-nix.nixosModules.raspberry-pi
            ./config/basics.nix
            ./config/ssh.nix
            ./services/dns.nix
          ];
        };
      };

      # Deployment targets
      deploy.nodes.some-random-system = {
        hostname = "192.168.0.13";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.aarch64-linux.activate.nixos
            self.nixosConfigurations.rpi5;
        };
      };
    };
}
