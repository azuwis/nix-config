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

  # for `home-manager switch` command even in nixos/nix-darwin
  home.packages = lib.mkIf (config.submoduleSupport.enable) [
    (pkgs.callPackage (inputs.home-manager + /home-manager) { path = inputs.home-manager; })
  ];

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
}
