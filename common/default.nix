{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getModules;
  inputs = import ../inputs;
in

{
  imports = [
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" config.my.user ])
  ] ++ getModules [ ./. ];

  _module.args.inputs = inputs;

  hm.imports = [ ./home.nix ];

  home-manager.useGlobalPkgs = true;
  # do not enable home-manager.useUserPackages, to match standalone home-manager,
  # so home-manager/nixos-rebuild/darwin-rebuild can be used at the same time
  # home-manager.useUserPackages = true;

  programs.yazi.enable = true;
  wrappers.difftastic.enable = true;
  wrappers.jujutsu.enable = true;
  wrappers.git.enable = true;

  wrappers.lazyvim.enable = true;
  wrappers.lazyvim.ansible.enable = true;
  wrappers.lazyvim.bash.enable = true;
  wrappers.lazyvim.custom.enable = true;
  wrappers.lazyvim.helm.enable = true;
  wrappers.lazyvim.mini-files.enable = true;
  wrappers.lazyvim.neogit.enable = true;
  wrappers.lazyvim.nix.enable = true;
  wrappers.lazyvim.nord.enable = true;
  wrappers.lazyvim.terraform.enable = true;
  # wrappers.lazyvim.yaml.enable = true;
  # wrappers.lazyvim.update-nix-fetchgit.enable = true;
}
