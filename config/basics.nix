{ pkgs, lib, ... }:
{
  # Set time
  time.timeZone = "Europe/Prague";

  # Enable flakes
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
   '';

   settings = {
     sandbox = true;
     auto-optimise-store = true;
     experimental-features = [ "nix-command" "flakes" ];
   };
  };

  # Must have packages
  environment.systemPackages = with pkgs; [ vim git htop dig wget curl which ];
}
