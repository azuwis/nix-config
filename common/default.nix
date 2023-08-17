{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" config.my.user ])
  ] ++ lib.my.getModules [ ./. ];

  hm.imports = [
    inputs.nix-index-database.hmModules.nix-index
  ] ++ lib.my.getHmModules [ ./. ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  hm = {
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
    systemd.user.startServices = "sd-switch";
  };
}
