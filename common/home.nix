{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ inputs.nix-index-database.hmModules.nix-index ] ++ lib.my.getHmModules [ ./. ];

  my = {
    difftastic.enable = true;
    direnv.enable = true;
    editorconfig.enable = true;
    # helix.enable = true;
    git.enable = true;
    # gitui.enable = true;
    less.enable = true;
    neovim.enable = true;
    yazi.enable = true;
    zsh.enable = true;
  };

  # let standalone home-manager and home-manager in nixos/nix-darwin use the same derivation
  home.packages = [
    (pkgs.callPackage (inputs.home-manager + /home-manager) { path = inputs.home-manager; })
  ];
  home.stateVersion = "23.11";
  systemd.user.startServices = "sd-switch";
}
