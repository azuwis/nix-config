{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib) getHmModules;
  inputs = import ../inputs;
in

{
  imports = getHmModules [ ./. ];

  my = {
    difftastic.enable = true;
    direnv.enable = true;
    editorconfig.enable = true;
    # helix.enable = true;
    jujutsu.enable = true;
    git.enable = true;
    # gitui.enable = true;
    less.enable = true;
    neovim.enable = true;
    nix-index.enable = true;
    yazi.enable = true;
    zsh.enable = true;
  };

  # let standalone home-manager and home-manager in nixos/nix-darwin use the same derivation
  home.packages = [
    (pkgs.callPackage "${inputs.home-manager.outPath}/home-manager" {
      path = inputs.home-manager.outPath;
    })
  ];
  home.stateVersion = "23.11";
  systemd.user.startServices = "sd-switch";
}
