{
  inputs = {
    # flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/master";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/pull/117/head";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    droid.url = "github:t184256/nix-on-droid/master";
    droid.inputs.nixpkgs.follows = "nixpkgs";
    droid.inputs.home-manager.follows = "home-manager";
    wsl.url = "github:nix-community/NixOS-WSL";
    wsl.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, flake-utils-plus, nixpkgs, darwin, droid, ... }:
    let
      inherit (flake-utils-plus.lib) mkFlake exportModules exportPackages exportOverlays;
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
      sharedOverlays = [ self.overlay flake-utils-plus.overlay ];

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
        ./hosts/wsl.nix
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
        modules = with self.modules; [ nixos desktop hyperv ];
      };

      hosts.wsl = {
        system = "x86_64-linux";
        modules = with self.modules; [ nixos desktop wsl ];
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
            overlays = [ self.overlay flake-utils-plus.overlay ];
          };
        };
      };

    };
}
