{
  description = "MacBook Pro";

  inputs = {
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgsUnstable";
    hmUnstable.url = "github:nix-community/home-manager";
    hmUnstable.inputs.nixpkgs.follows = "nixpkgsUnstable";
    # https://hydra.nixos.org/jobset/nixpkgs/nixpkgs-unstable-aarch64-darwin
    nixpkgsUnstable.url = "github:nixos/nixpkgs/74c63a1";
  };

  outputs = { self, darwin, hmUnstable, nixpkgsUnstable }: {
    darwinConfigurations."mbp" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        {
          nix.nixPath = [ "nixpkgs=${nixpkgsUnstable}" ];
          nix.registry.local = {
            flake = nixpkgsUnstable;
            from = { id = "local"; type = "indirect"; };
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
        hmUnstable.darwinModules.home-manager
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
  };
}
