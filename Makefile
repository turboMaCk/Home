RPI_REMOTE=root@192.168.0.4

.PHONY: deploy-rpi
deploy-rpi:
	nixos-rebuild switch --flake .#rpi5 --target-host $(RPI_REMOTE) --build-host $(RPI_REMOTE)

.PHONY: deploy
deploy: deploy-rpi

.PHONY: bootstrap-rpi
bootstrap-rpi:
	nixos-anywhere --flake .#rpi $(RPI_REMOTE)

rpi5-boot-result:
	nix build .#rpi5-boot --out-link $@

rpi5-boot.img: rpi5-boot-result
	nix run nixpkgs#zstd -- -d $^/sd-image/nixos-image-rpi5-kernel.img.zst -o $@

.PHONY: clean
clean:
	$(RM) rpi-boot-result rpi5-boot.img
