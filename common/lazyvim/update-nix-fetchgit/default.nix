{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.wrappers.lazyvim.update-nix-fetchgit;

  update-nix-fetchgit-vim = pkgs.vimUtils.buildVimPlugin {
    pname = "update-nix-fetchgit.vim";
    version = "2022-01-25";
    src = lib.fileset.toSource {
      root = ./.;
      fileset = ./ftplugin;
    };
  };
in

{
  options.wrappers.lazyvim.update-nix-fetchgit = {
    enable = mkEnableOption "LazyVim update-nix-fetchgit support";
  };

  config = lib.mkIf cfg.enable {
    wrappers.lazyvim = {
      extraPackages = [ pkgs.update-nix-fetchgit ];
      extraPlugins = [ update-nix-fetchgit-vim ];
      config.update-nix-fetchgit = ./spec.lua;
    };
  };
}
