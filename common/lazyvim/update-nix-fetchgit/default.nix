{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.update-nix-fetchgit;

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
  options.my.lazyvim.update-nix-fetchgit = {
    enable = mkEnableOption "LazyVim update-nix-fetchgit support";
  };

  config = lib.mkIf cfg.enable {
    my.lazyvim.extraPlugins = [
      update-nix-fetchgit-vim
    ];

    programs.neovim.extraPackages = with pkgs; [
      update-nix-fetchgit
    ];

    xdg.configFile."nvim/lua/plugins/update-nix-fetchgit.lua".source = ./spec.lua;
  };
}
