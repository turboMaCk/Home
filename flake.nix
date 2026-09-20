{
  description = "turbo_MaCk's home infrastructure";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    };
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs = { self, nixpkgs, nixos-raspberrypi, deploy-rs, disko, nixos-anywhere }@inputs:
    let
      inherit (nixpkgs.lib) nixosSystem;
      # rpi5-boot = import ./images/rpi5-boot.nix;

      allSystems = [
        "x86_64-linux" # 64bit AMD/Intel x86
        "aarch64-linux" # 64bit ARM Linux
      ];

      forAllSystems = fn:
        nixpkgs.lib.genAttrs allSystems
          (system: fn {
            pkgs = import nixpkgs { inherit system; };
            anywhere = nixos-anywhere.packages.${system}.default;
          });

      mkImage = nixosConfig: nixosConfig.config.system.build.sdImage;
    in {
      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      devShells = forAllSystems ({ pkgs, anywhere }: {
        default = pkgs.mkShell {
          name = "Home-deploy/build-shell";
          buildInputs = [ pkgs.deploy-rs anywhere ];
        };
      });

      packages = forAllSystems ({ pkgs, ... }: {
        rpi5-boot = mkImage self.nixosConfigurations.rpi5-boot;
      });

      # System configurations
      nixosConfigurations = {
        rpi5-boot = nixos-raspberrypi.lib.nixosInstaller {
          system = "aarch64-linux";
          specialArgs = inputs;

          modules = with nixos-raspberrypi.nixosModules; [
            raspberry-pi-5.base
            raspberry-pi-5.page-size-16k
            raspberry-pi-5.display-vc4
            raspberry-pi-5.bluetooth
            ./config/basics.nix
            ./config/ssh.nix
            ({ config, pkgs, ... }: {
              networking = {
                hostName = "rpi5";
                useDHCP = false;
                interfaces = {
                  wlan0.useDHCP = true;
                  eth0.useDHCP = true;
                };
              };
            })
          ];
        };

        rpi5 = nixos-raspberrypi.lib.nixosSystemFull {
          system = "aarch64-linux";
          specialArgs = inputs;

          modules = [
            ({ config, pkgs, lib, nixos-raspberrypi, disko, ... }: {
              imports = with nixos-raspberrypi.nixosModules; [
                # Hardware configuration
                raspberry-pi-5.base
                raspberry-pi-5.page-size-16k
                raspberry-pi-5.display-vc4
              ];
              hardware.raspberry-pi.config = {
                all = {
                  base-dt-params = {
                    i2c = {
                      enable = true;
                      value = "on";
                    };
                  };
                };
              };
            })

            # Disk formatting
            disko.nixosModules.disko

            {
              boot.loader.raspberry-pi.bootloader = "kernel";
              boot.tmp.useTmpfs = true;
            }

            ({ config, pkgs, lib, ... }: {
              system.nixos.tags = let
                cfg = config.boot.loader.raspberry-pi;
              in [
                "raspberry-pi-${cfg.variant}"
                cfg.bootloader
                config.boot.kernelPackages.kernel.version
              ];
            })

            ./devices/rpi5.nix
            ./config/basics.nix
            ./config/ssh.nix
          # ./config/containers.nix
          #  ./services/dns.nix
          #  ./services/home-assistant.nix
          #  ./services/reverse-proxy.nix
          ];
        };

        thinkcentre = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./devices/thinkcentre.nix
            ./config/basics.nix
            ./config/ssh.nix
            # ./services/sonarr.nix
            ./services/jellyfin.nix
          ];
        };
      };

      # Deployment targets
      deploy = {
        nodes = {
          thinkcentre = {
            hostname = "192.168.0.5";
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
