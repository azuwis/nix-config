{ inputs, config, lib, pkgs, ... }:

{
  imports = lib.my.getModules [ ../modules/common ];

  hm.imports = [
    inputs.nix-index-database.hmModules.nix-index
  ] ++ lib.my.getHmModules [ ../modules/common ];

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

    home.stateVersion = "22.05";
    systemd.user.startServices = "sd-switch";
  };
}
