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

### DNS

I'm running local [blocky](https://github.com/0xERR0R/blocky) instance which is somewhat similar to pi-hole but more sane especially
for infrastructure as a code type of setups.
This also configures network wide ad blocking
and some other DNS based protections network wide.

To test the DNS you can use dig utility:

```
dig NS github.com
```

To test the DNS server before configuring network simply:

```
nslookup {ip-of-dns-server} github.com
```

## Deploying

Infrastructure can be automatically deployed to devices using [deploy-rs](https://github.com/serokell/deploy-rs).

```
nix run nixpkgs#deploy-rs
```



## Build SD card images for Raspberry PI

Useful for bootstrapping new devices.
This flashes my base NixOS system onto the SD card.
From that point on, the deploy-rs flow is used to configure the device to desired configuration.

Build of rpi kernel takes ages. The best way to work around this is to use [elm-community cachix](https://app.cachix.org/cache/nix-community).

```
cachix use nix-community
```

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
