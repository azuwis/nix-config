{ config, pkgs, ... }:

{
  imports = [
    <home-manager/nix-darwin>
    ./homebrew.nix
    ./sudo.nix
    ./vim.nix
    ./yabai.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # vim
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 20;
    KeyRepeat = 2;
  };
  system.defaults.dock.autohide = true;
  system.defaults.trackpad = {
    Clicking = true;
    Dragging = true;
    TrackpadThreeFingerDrag = true;
  };
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # Home Manager
  # nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.azuwis = import ./home.nix { email = "azuwis@gmail.com"; name = "Zhong Jianxin"; };
  environment.pathsToLink = [ "/share/zsh" ];
}
