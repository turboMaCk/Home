# Home

My home infrastructure.

# Build SD card images for Raspberry PI

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
