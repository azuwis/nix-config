{
  inputs = {
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "darwinNixpkgs";
    darwinHm.url = "github:nix-community/home-manager/master";
    darwinHm.inputs.nixpkgs.follows = "darwinNixpkgs";
    # https://hydra.nixos.org/jobset/nixpkgs/nixpkgs-unstable-aarch64-darwin
    darwinNixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    droid.url = "github:t184256/nix-on-droid";
    droid.inputs.nixpkgs.follows = "droidNixpkgs";
    droid.inputs.home-manager.follows = "droidHm";
    droidHm.url = "github:nix-community/home-manager/release-21.11";
    droidHm.inputs.nixpkgs.follows = "droidNixpkgs";
    droidNixpkgs.url = "github:NixOS/nixpkgs/release-21.11";

    nixos.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixosHm.url = "github:nix-community/home-manager/master";
    nixosHm.inputs.nixpkgs.follows = "nixos";
  };

  outputs = inputs@{ self, darwin, darwinHm, darwinNixpkgs, droid, droidNixpkgs, nixos, nixosHm, ... }: {
    darwinConfigurations.mbp = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = inputs;
      modules = [
        ./darwin
      ];
    };

    nixOnDroidConfigurations.device = droid.lib.nixOnDroidConfiguration rec {
      system = "aarch64-linux";
      pkgs = import droidNixpkgs {
        inherit system;
        overlays = import ./common/overlays.nix;
      };
      config = {
        imports = [
          ./droid/sshd.nix
          ./droid/system.nix
          ./droid/termux.nix
        ];
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.config = { imports = [
          ./common/direnv.nix
          ./common/git.nix
          ./common/gnupg.nix
          ./common/my.nix
          ./common/neovim
          ./common/nnn
          ./common/packages.nix
          ./common/zsh-ssh-agent.nix
          ./common/zsh.nix
          ./droid/compat.nix
          ./droid/gnupg.nix
          ./droid/packages.nix
        ]; };
      };
    };

    nixosConfigurations.nuc = nixos.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        (import ./common/system.nix { nixpkgs = nixos; })
        ./common/my.nix
        ./nixos/nuc.nix
        # nixos-generate-config --show-hardware-config > nixos/nuc-hardware.nix
        ./nixos/nuc-hardware.nix
        ./nixos/system.nix
        nixosHm.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.azuwis = { imports = [
            ./common/direnv.nix
            ./common/git.nix
            ./common/mpv.nix
            ./common/my.nix
            ./common/neovim
            ./common/nix-index.nix
            ./common/packages.nix
            ./common/zsh.nix
            ./nixos/packages.nix
          ]; };
        }
      ];
    };

    nixosConfigurations.utm = nixos.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        (import ./common/system.nix { nixpkgs = nixos; })
        ./common/my.nix
        ./nixos/utm.nix
        # nixos-generate-config --show-hardware-config > nixos/utm-hardware.nix
        ./nixos/utm-hardware.nix
        ./nixos/system.nix
        nixosHm.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.azuwis = { imports = [
            ./common/direnv.nix
            ./common/git.nix
            ./common/my.nix
            ./common/neovim
            ./common/nix-index.nix
            ./common/nnn
            ./common/packages.nix
            ./common/zsh.nix
            ./nixos/packages.nix
          ]; };
        }
      ];
    };
  };
}
