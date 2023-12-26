{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    droid.url = "github:nix-community/nix-on-droid";
    droid.inputs.nixpkgs.follows = "nixpkgs";
    droid.inputs.home-manager.follows = "home-manager";
    wsl.url = "github:nix-community/NixOS-WSL";
    wsl.inputs.nixpkgs.follows = "nixpkgs";
    wsl.inputs.flake-utils.follows = "flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.darwin.follows = "darwin";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";
    agenix.inputs.systems.follows = "systems";
    nvidia-patch.url = "github:icewind1991/nvidia-patch-nixos";
    nvidia-patch.inputs.nixpkgs.follows = "nixpkgs";
    nvidia-patch.inputs.utils.follows = "flake-utils";
    # devshell.url = "github:numtide/devshell";
    # devshell.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];
      imports = [ ./flakes ];
    };
}
