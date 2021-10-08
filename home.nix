{ config, lib, pkgs, ... }:

{
  imports = import ./modules.nix { inherit lib; };
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
    borgbackup
    coreutils-full
    curl
    fmenu
    gnupg
    htop
    hydra-check
    less
    openssh
    pass-otp
    ripgrep
    shellcheck
    telnet
    watch
    wireguard
  ];
}
