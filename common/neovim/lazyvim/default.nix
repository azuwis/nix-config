{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.my.neovim.enable {
    my.lazyvim.enable = true;
    my.lazyvim.ansible.enable = true;
    my.lazyvim.bash.enable = true;
    my.lazyvim.custom.enable = true;
    my.lazyvim.helm.enable = true;
    my.lazyvim.mini-files.enable = true;
    my.lazyvim.neogit.enable = true;
    my.lazyvim.nix.enable = true;
    my.lazyvim.nord.enable = true;
    my.lazyvim.terraform.enable = true;
    # my.lazyvim.yaml.enable = true;
    # my.lazyvim.update-nix-fetchgit.enable = true;
  };
}
