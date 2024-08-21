{ pkgs, lib, ... }: {

  # Set time
  time.timeZone = "Europe/Prague";

  # Enable flakes
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
   '';

    settings.sandbox = true;
  };

  # Must have packages
  environment.systemPackages = with pkgs; [ vim git ];
}
