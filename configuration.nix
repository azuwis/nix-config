{ config, lib, pkgs, ... }:

{
  # nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
  # nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  # nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
  imports = [
    <home-manager/nix-darwin>
    ./services/redsocks2
    ./services/shadowsocks
    ./services/smartdns
    ./homebrew.nix
    ./kitty.nix
    ./my.nix
    ./skhd.nix
    ./smartnet.nix
    ./spacebar
    ./squirrel.nix
    ./sudo.nix
    ./system.nix
    ./yabai.nix
  ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users."${config.my.user}" = import ./home.nix;

  services.lorri.enable = true;
}
