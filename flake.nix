{
  description = "turbo_MaCk's home infrastructure";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, raspberry-pi-nix, deploy-rs }:
    let
      inherit (nixpkgs.lib) nixosSystem;
      rpi5-boot = import ./images/rpi5-boot.nix;

      allSystems = [
        "x86_64-linux" # 64bit AMD/Intel x86
        "aarch64-linux" # 64bit ARM Linux
      ];

      forAllSystems = fn:
        nixpkgs.lib.genAttrs allSystems
          (system: fn {
            pkgs = import nixpkgs { inherit system; };
          });

    in {
      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          name = "Home-deploy/build-shell";
          buildInputs = [ pkgs.deploy-rs ];
        };
      });

      # System configurations
      nixosConfigurations = {
        # Basic image just for botting NixOS on rpi5
        rpi5-boot = nixosSystem {
          system = "aarch64-linux";
          modules = [
            raspberry-pi-nix.nixosModules.raspberry-pi
            ./images/rpi5-boot.nix
            ./config/basics.nix
            ./config/ssh.nix
          ];
        };

        rpi5 = nixosSystem {
          system = "aarch64-linux";
          modules = [
            raspberry-pi-nix.nixosModules.raspberry-pi
            ./devices/rpi5.nix
            ./config/basics.nix
            ./config/ssh.nix
            ./config/containers.nix
            ./services/dns.nix
            ./services/home-assistant.nix
            ./services/reverse-proxy.nix
          ];
        };

        thinkcentre = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./devices/thinkcentre.nix
            ./config/basics.nix
            ./config/ssh.nix
            ./services/sonarr.nix
            ./services/jellyfin.nix
          ];
        };
      };

      # Deployment targets
      deploy = {
        nodes = {
          thinkcentre = {
            hostname = "thinkcentre.local";
            profiles.system = {
              user = "root";
              sshUser = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos
                self.nixosConfigurations.thinkcentre;
            };
          };
          rpi5 = {
            hostname = "192.168.0.4";
            profiles.system = {
              user = "root";
              sshUser = "root";
              path = deploy-rs.lib.aarch64-linux.activate.nixos
                self.nixosConfigurations.rpi5;
            };
          };
        };
      };
    };
}
