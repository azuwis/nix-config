{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.helm;
in
{
  options.my.lazyvim.helm = {
    enable = mkEnableOption "LazyVim helm support";
  };

  config = lib.mkIf cfg.enable {
    my.lazyvim.extraPlugins = with pkgs.vimPlugins; [
      vim-helm
    ];

    programs.neovim.extraPackages = with pkgs; [
      helm-ls
    ];

    xdg.configFile."nvim/lua/plugins/helm.lua".source = ./spec.lua;
  };
}
