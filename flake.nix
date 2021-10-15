{
  description = "MacBook Pro";

  inputs = {
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # https://hydra.nixos.org/jobset/nixpkgs/nixpkgs-unstable-aarch64-darwin
    nixpkgs.url = "github:nixos/nixpkgs/74c63a1";
  };

  outputs = { self, darwin, home-manager, nixpkgs }: {
    darwinConfigurations."mbp" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        {
          nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
          nix.registry.local = {
            flake = nixpkgs;
            from = { id = "local"; type = "indirect"; };
          };
        }
        ./configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.azuwis = import ./home.nix;
        }
      ];
    };
  };
}
