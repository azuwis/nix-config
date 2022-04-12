{
  inputs = {
    # utils.url = "github:gytis-ivaskevicius/flake-utils-plus/master";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus/pull/117/head";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    droid.url = "github:azuwis/nix-on-droid/master";
    droid.inputs.nixpkgs.follows = "nixpkgs";
    droid.inputs.home-manager.follows = "home";
    home.url = "github:nix-community/home-manager/master";
    home.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, utils, nixpkgs, darwin, droid, ... }:
    let
      inherit (utils.lib) mkFlake exportModules exportPackages exportOverlays;
    in
    mkFlake {
      inherit self inputs;

      channelsConfig = {
        allowUnfree = true;
      };

      overlay = import ./overlay.nix;
      overlays = exportOverlays {
        inherit (self) pkgs inputs;
      };
      sharedOverlays = [ self.overlay utils.overlay ];

      outputsBuilder = channels: {
        packages = exportPackages self.overlays channels;
      };

      modules = exportModules [
        ./common
        ./darwin
        ./nixos
        ./nixos/desktop.nix
        ./hosts/nuc.nix
        ./hosts/utm.nix
        ./hosts/hyperv.nix
      ];

      hostDefaults = {
        modules = [ self.modules.common ];
        specialArgs = { inherit inputs; };
      };

      hosts.mbp = {
        system = "aarch64-darwin";
        modules = [ self.modules.darwin ];
        output = "darwinConfigurations";
        builder = darwin.lib.darwinSystem;
      };

      hosts.nuc = {
        system = "x86_64-linux";
        modules = with self.modules; [ nixos desktop nuc ];
      };

      hosts.utm = {
        system = "aarch64-linux";
        modules = with self.modules; [ nixos utm ];
      };

      hosts.hyperv = {
        system = "x86_64-linux";
        modules = with self.modules; [ nixos hyperv ];
      };

      hosts.droid = {
        system = "aarch64-linux";
        modules = [ ./droid ];
        output = "nixOnDroidConfigurations";
        builder = { system, modules, ... } :
        droid.lib.nixOnDroidConfiguration {
          inherit system;
          config = { imports = modules; };
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlay utils.overlay ];
          };
        };
      };

    };
}
