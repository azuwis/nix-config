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

  outputs = { self, darwin, darwinHm, darwinNixpkgs, droid, droidNixpkgs, nixos, nixosHm, ... }:
    let
      modules = rec {
        common = [
          ./common/my.nix
          ./common/system.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
        darwin = common ++ [
          (import ./common/registry.nix { nixpkgs = darwinNixpkgs; })
          ./common/rime
          ./darwin/age.nix
          ./darwin/agenix.nix
          ./darwin/emacs # emacs-all-the-icons-fonts
          ./darwin/firefox.nix
          ./darwin/homebrew.nix
          ./darwin/hostname.nix
          ./darwin/kitty.nix # sudo keep TERMINFO_DIRS env
          ./darwin/my.nix
          ./darwin/sketchybar
          ./darwin/skhd.nix
          ./darwin/smartnet.nix
          ./darwin/sudo.nix
          ./darwin/system.nix
          ./darwin/wireguard.nix
          ./darwin/yabai.nix
          ./services/redsocks2
          ./services/shadowsocks
          ./services/sketchybar
          ./services/smartdns
          darwinHm.darwinModules.home-manager
        ];
        nixos = common ++ [
          (import ./common/registry.nix { nixpkgs = nixos; })
          ./nixos/system.nix
          nixosHm.nixosModules.home-manager
        ];
      };
      modulesHm = rec {
        common = [
          ./common/direnv.nix
          ./common/git.nix
          ./common/gnupg.nix
          ./common/mpv.nix
          ./common/my.nix
          ./common/neovim
          ./common/nnn
          ./common/nix-index.nix
          ./common/packages.nix
          ./common/zsh.nix
        ];
        darwin = common ++ [
            ./common/alacritty.nix
            ./common/firefox
            ./common/rime
            ./common/zsh-ssh-agent.nix
            ./darwin/emacs
            ./darwin/firefox.nix
            ./darwin/hmapps.nix
            ./darwin/kitty.nix
            ./darwin/packages.nix
            ./darwin/skhd.nix
        ];
        nixos = common ++ [
          ./nixos/packages.nix
        ];
      };
    in {
    darwinConfigurations.mbp = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = modules.darwin ++ [
        {
          home-manager.users.azuwis = { imports = modulesHm.darwin ++ [
          ]; };
        }
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
        home-manager.config = { imports = modulesHm.common ++ [
          ./common/zsh-ssh-agent.nix
          ./droid/compat.nix
          ./droid/gnupg.nix
          ./droid/packages.nix
        ]; };
      };
    };

    nixosConfigurations.nuc = nixos.lib.nixosSystem {
      system = "x86_64-linux";
      modules = modules.nixos [
        ./nixos/nuc.nix
        # nixos-generate-config --show-hardware-config > nixos/utm-hardware.nix
        ./nixos/nuc-hardware.nix
        {
          home-manager.users.azuwis = { imports = modulesHm.nixos ++ [
          ]; };
        }
      ];
    };

    nixosConfigurations.utm = nixos.lib.nixosSystem {
      system = "aarch64-linux";
      modules = modules.nixos ++ [
        ./nixos/utm.nix
        # nixos-generate-config --show-hardware-config > nixos/utm-hardware.nix
        ./nixos/utm-hardware.nix
        {
          home-manager.users.azuwis = { imports = modulesHm.nixos ++ [
          ]; };
        }
      ];
    };
  };
}
