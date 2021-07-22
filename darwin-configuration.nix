{ config, pkgs, ... }:

{
  imports = [ <home-manager/nix-darwin> ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
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

  homebrew = {
    enable = true;
    cleanup = "zap";
    brewPrefix = "/opt/homebrew/bin";
    taps = [
      "homebrew/cask"
      "homebrew/homebrew-services"
      "xorpse/formulae"
    ];
    brews = [
    ];
    casks = [
    ];
    extraConfig = ''
      brew "xorpse/formulae/yabai", args:["HEAD"]
    '';
    masApps = {
      # Xcode = 497799835;
    };
  };

  environment.variables = {
    EDITOR = "vim";
  };
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
  system.patches = [
    (pkgs.writeText "pam-sudo.patch" ''
      --- a/etc/pam.d/sudo
      +++ b/etc/pam.d/sudo
      @@ -1,4 +1,5 @@
       # sudo: auth account password session
      +auth       sufficient     pam_tid.so
       auth       sufficient     pam_smartcard.so
       auth       required       pam_opendirectory.so
       account    required       pam_permit.so
    '')
  ];

  # Home Manager
  # nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.azuwis = import ./home.nix { email = "azuwis@gmail.com"; name = "Zhong Jianxin"; };
  environment.pathsToLink = [ "/share/zsh" ];
}
