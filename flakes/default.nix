{ inputs, ... }:

{
  imports = [
    ./overlays.nix
    ./darwin-vm.nix
  ];
}
