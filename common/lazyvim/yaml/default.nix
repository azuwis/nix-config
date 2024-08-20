{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption;
  cfg = config.my.lazyvim.yaml;
  yaml = pkgs.formats.yaml { };
in
{
  options.my.lazyvim.yaml = {
    enable = mkEnableOption "LazyVim yaml support";

    settings = mkOption {
      type = yaml.type;
      default = {
        # https://github.com/google/yamlfmt/blob/main/docs/config-file.md
        formatter = {
          type = "basic";
          drop_merge_tag = true;
          retain_line_breaks_single = true;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.neovim.extraPackages = with pkgs; [ yamlfmt ];

    my.neovim.treesitterParsers = [ "yaml" ];

    xdg.configFile."nvim/lua/plugins/yaml.lua".source = ./spec.lua;

    xdg.configFile."yamlfmt.yaml".source = yaml.generate "yamlfmt.yaml" cfg.settings;
  };
}
