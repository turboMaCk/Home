{
  description = "turbo_MaCk's home infrastructure";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs = { self, nixpkgs, nixos-raspberrypi, deploy-rs }@inputs:
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
        # rpi5-boot = nixosSystem {
        #   system = "aarch64-linux";
        #   modules = [
        #     raspberry-pi-nix.nixosModules.raspberry-pi
        #     raspberry-pi-nix.nixosModules.sd-image
        #     ./images/rpi5-boot.nix
        #     ./config/basics.nix
        #     ./config/ssh.nix
        #   ];
        # };

        rpi5 = nixos-raspberrypi.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = inputs;

          modules = with nixos-raspberrypi.nixosModules; [
            {
              # Hardware specific configuration, see section below for a more complete
              # list of modules
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-5.base
                raspberry-pi-5.display-vc4
                raspberry-pi-5.bluetooth
              ];
            }

            ({ config, pkgs, lib, ... }: {
              system.nixos.tags = let
                cfg = config.boot.loader.raspberry-pi;
              in [
                "raspberry-pi-${cfg.variant}"
                cfg.bootloader
                config.boot.kernelPackages.kernel.version
              ];

              hardware.raspberry-pi.config = {
                all = { # [all] conditional filter, https://www.raspberrypi.com/documentation/computers/config_txt.html#conditional-filters

                  options = {
                    # https://www.raspberrypi.com/documentation/computers/config_txt.html#enable_uart
                    # in conjunction with `console=serial0,115200` in kernel command line (`cmdline.txt`)
                    # creates a serial console, accessible using GPIOs 14 and 15 (pins
                    #  8 and 10 on the 40-pin header)
                    enable_uart = {
                      enable = true;
                      value = true;
                    };
                    # https://www.raspberrypi.com/documentation/computers/config_txt.html#uart_2ndstage
                    # enable debug logging to the UART, also automatically enables
                    # UART logging in `start.elf`
                    uart_2ndstage = {
                      enable = true;
                      value = true;
                    };
                  };

                  # Base DTB parameters
                  # https://github.com/raspberrypi/linux/blob/a1d3defcca200077e1e382fe049ca613d16efd2b/arch/arm/boot/dts/overlays/README#L132
                  base-dt-params = {

                    # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#enable-pcie
                    pciex1 = {
                      enable = true;
                      value = "on";
                    };

                    # PCIe Gen 3.0
                    # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#pcie-gen-3-0
                    pciex1_gen = {
                      enable = true;
                      value = "3";
                    };

                  };
                };
              };
            })

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
