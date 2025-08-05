{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.wrappers.lazyvim.custom;
in
{
  options.wrappers.lazyvim.custom = {
    enable = mkEnableOption "LazyVim custom settings";
  };

  config = lib.mkIf cfg.enable {
    wrappers.lazyvim = {
      extraPlugins = [
        {
          name = "mini.surround";
          path = pkgs.vimPlugins.mini-nvim;
        }
      ];
      config.custom = pkgs.replaceVarsWith {
        src = ./spec.lua;
        replacements = {
          # Need to use builtins.path to force copy ./snippets to nix store
          snippets = builtins.path { path = ./snippets; };
        };
      };
      config."lua/config" = ./config;
    };
  };
}
