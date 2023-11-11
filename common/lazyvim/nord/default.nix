{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.nord;

  nord-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "nord.nvim";
    version = "2023-11-10";
    src = pkgs.fetchFromGitHub {
      owner = "gbprod";
      repo = "nord.nvim";
      rev = "74b5032dd7a600b849eab769b52401bccb6d8d41";
      sha256 = "sha256-njZRvB6pcRQcrfGrcOAX5z/VqGtdIKgzEBUjEbvG6pI=";
    };
    meta.homepage = "https://github.com/gbprod/nord.nvim/";
  };
in
{
  options.my.lazyvim.nord = {
    enable = mkEnableOption "LazyVim nord theme";
  };

  config = lib.mkIf cfg.enable {
    my.lazyvim.extraPlugins = [
      nord-nvim
    ];

    xdg.configFile."nvim/lua/plugins/nord.lua".source = ./spec.lua;
  };
}
