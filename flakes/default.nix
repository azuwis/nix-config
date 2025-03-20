{ inputs, ... }:

{
  imports = [
    inputs.devshell.flakeModule
    ./overlays.nix
    ./openwrt.nix
    ./treefmt.nix
    # ./devshell.nix
    ./devshell-android.nix
    ./devshell-droid.nix
    ./darwin-vm.nix
  ];
}
