{
  inputs = {
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgsDarwin";
    hmDarwin.url = "github:nix-community/home-manager/master";
    hmDarwin.inputs.nixpkgs.follows = "nixpkgsDarwin";
    # https://hydra.nixos.org/jobset/nixpkgs/nixpkgs-unstable-aarch64-darwin
    nixpkgsDarwin.url = "github:nixos/nixpkgs/02cea62";

    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixosHm.url = "github:nix-community/home-manager/master";
    nixosHm.inputs.nixpkgs.follows = "nixos";
  };

  outputs = { self, darwin, hmDarwin, nixpkgsDarwin, nixos, nixosHm }: {
    darwinConfigurations."mbp" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        {
          nix.nixPath = [ "nixpkgs=${nixpkgsDarwin}" ];
          nix.registry.l = {
            flake = nixpkgsDarwin;
            from = { id = "l"; type = "indirect"; };
          };
        }
        ./common/my.nix
        ./common/system.nix
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
        ./darwin/yabai.nix
        ./services/redsocks2
        ./services/shadowsocks
        ./services/sketchybar
        ./services/smartdns
        hmDarwin.darwinModules.home-manager
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
