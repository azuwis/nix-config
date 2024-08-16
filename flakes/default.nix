{ inputs, ... }:

{
  imports = [
    inputs.devshell.flakeModule
    ./lib.nix
    ./overlays.nix
    ./darwin.nix
    ./nixos.nix
    ./droid.nix
    # ./devshell.nix
    ./home-manager.nix
    ./openwrt.nix
    ./treefmt.nix
  ];
}
