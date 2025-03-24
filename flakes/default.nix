{ inputs, ... }:

{
  imports = [
    ./overlays.nix
    ./openwrt.nix
    ./darwin-vm.nix
  ];
}
