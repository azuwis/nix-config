{ config, lib, pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./git.nix
    ./kitty.nix
    ./mpv.nix
    ./my.nix
    ./neovim.nix
    ./skhd.nix
    ./squirrel.nix
    ./zsh.nix
  ];
  home.file."Applications/Home Manager Apps".source =
    let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in
    "${apps}/Applications";
  home.packages = with pkgs; [
    coreutils-full
    curl
    fmenu
    gnupg
    htop
    hydra-check
    less
    openssh_8_7
    pass-otp
    ripgrep
    watch
  ];
  programs.direnv.enable = true;
}
