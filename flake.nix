{
  inputs = {
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "darwinNixpkgs";
    darwinHm.url = "github:nix-community/home-manager/master";
    darwinHm.inputs.nixpkgs.follows = "darwinNixpkgs";
    # https://hydra.nixos.org/jobset/nixpkgs/nixpkgs-unstable-aarch64-darwin
    darwinNixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixosHm.url = "github:nix-community/home-manager/master";
    nixosHm.inputs.nixpkgs.follows = "nixos";
  };

  outputs = { self, darwin, darwinHm, darwinNixpkgs, nixos, nixosHm }: {
    darwinConfigurations."mbp" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        {
          nix.nixPath = [ "nixpkgs=${darwinNixpkgs}" ];
          nix.registry.l.flake = darwinNixpkgs;
        }
        ./common/my.nix
        ./common/system.nix
        ./darwin/age.nix
        ./darwin/agenix.nix
        ./darwin/emacs # emacs-all-the-icons-fonts
        ./darwin/homebrew.nix
        ./darwin/hostname.nix
        ./darwin/kitty.nix # sudo keep TERMINFO_DIRS env
        ./darwin/sketchybar
        ./darwin/skhd.nix
        ./darwin/smartnet.nix
        ./darwin/squirrel.nix
        ./darwin/sudo.nix
        ./darwin/system.nix
        ./darwin/wireguard.nix
        ./darwin/yabai.nix
        ./services/redsocks2
        ./services/shadowsocks
        ./services/sketchybar
        ./services/smartdns
        darwinHm.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.azuwis = { imports = [
            ./common/alacritty.nix
            ./common/direnv.nix
            ./common/git.nix
            ./common/mpv.nix
            ./common/my.nix
            ./common/neovim.nix
            ./common/packages.nix
            ./common/zsh.nix
            ./darwin/emacs
            ./darwin/hmapps.nix
            ./darwin/kitty.nix
            ./darwin/packages.nix
            ./darwin/skhd.nix
            ./darwin/squirrel.nix
          ]; };
        }
      ];
    };

    nixosConfigurations.nuc = nixos.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nix.nixPath = [ "nixpkgs=${nixos}" ];
          nix.registry.l = {
            flake = nixos;
            from = { id = "l"; type = "indirect"; };
          };
        }
        ./common/my.nix
        ./common/system.nix
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
            ./common/neovim.nix
            ./common/packages.nix
            ./common/zsh.nix
            ./nixos/packages.nix
          ]; };
        }
      ];
    };
  };
}
