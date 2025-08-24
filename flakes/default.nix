{
  darwinConfigurations = import ./darwin.nix;
  nixosConfigurations = import ./nixos.nix;
  nixOnDroidConfigurations = import ./droid.nix;
  soloConfigurations = import ./solo.nix;
  homeConfigurations = import ./home-manager.nix;
  openwrtConfigurations = import ./openwrt.nix;
}
