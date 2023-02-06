{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
    flake-utils-plus.inputs.flake-utils.follows = "flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nixpkgsDarwin.url = "github:NixOS/nixpkgs/nixpkgs-22.05-darwin";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    droid.url = "github:t184256/nix-on-droid";
    droid.inputs.nixpkgs.follows = "nixpkgs";
    droid.inputs.home-manager.follows = "home-manager";
    wsl.url = "github:nix-community/NixOS-WSL";
    wsl.inputs.nixpkgs.follows = "nixpkgs";
    wsl.inputs.flake-utils.follows = "flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.darwin.follows = "darwin";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
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
        # channelName = "nixpkgsDarwin";
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
