{ inputs, config, lib, pkgs, ... }:

{
  imports = lib.my.getModules [ ../modules/common ];

  hm.imports = [
    inputs.nix-index-database.hmModules.nix-index
    ./difftastic.nix
    ./direnv.nix
    ./helix.nix
    ./git.nix
  ] ++ lib.my.getHmModules [ ../modules/common ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  hm = {
    my = {
      gitui.enable = true;
      neovim.enable = true;
      nnn.enable = true;
      zsh.enable = true;
    };

    home.stateVersion = "22.05";
    systemd.user.startServices = "sd-switch";
  };
}
