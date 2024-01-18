{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
  ] ++ lib.my.getHmModules [ ./. ];

  my = {
    difftastic.enable = true;
    direnv.enable = true;
    # helix.enable = true;
    git.enable = true;
    # gitui.enable = true;
    neovim.enable = true;
    nnn.enable = true;
    zsh.enable = true;
  };

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
}
