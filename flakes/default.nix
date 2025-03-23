{ inputs, ... }:

{
  imports = [
    ./overlays.nix
    ./openwrt.nix
    ./treefmt.nix
    ./darwin-vm.nix
  ];
}
