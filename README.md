# Home

My home infrastructure.

## Network

I'm using [SDN](https://en.wikipedia.org/wiki/Software-defined_networking) solution
from TP-Link called 'Omada' to setup my networking infrastructure including Virtual networks and VPN.
This configuration lives in the Omada controller and is not contained within this repository
but is crucial for whole infrastructure to work.

## Hardware & Services

Apart from router, switches, network controller and access points
I'm running most of my setup on top of [NixOS](https://nixos.org/)
using these devices:

- Rapsberry PI 5 with PoE Hat
  - DNS server

## DNS


## Build SD card images for Raspberry PI

Useful for bootstrapping new devices.
This flashes my base NixOS system onto the SD card.
From that point on, the deploy-rs flow is used to configure the device to desired configuration.

> On x86 this requires QEMU for building for AARCH64
>
> Make sure your system is configured with:
>
> ```
> boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
> ```

Build image using nix:

```
nix build '.#nixosConfigurations.rpi5-boot.config.system.build.sdImage'
```

unpack:

```
nix run nixpkgs#zstd -- -d result/sd-image/{name-of-the-file}.img.zst -o image.img
```

Flash to the device:

```
sudo dd if=image.img of=/dev/{device} bs=4096 conv=fsync status=progress
```
