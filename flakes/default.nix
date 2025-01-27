{ inputs, ... }:

{
  imports = [
    inputs.devshell.flakeModule
    ./lib.nix
    ./overlays.nix
    ./darwin.nix
    ./nixos.nix
    ./droid.nix
    ./home-manager.nix
    ./openwrt.nix
    ./treefmt.nix
    # ./devshell.nix
    ./devshell-android.nix
    ./darwin-vm.nix
  ];
}
