{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption;
  cfg = config.programs.lazyvim.yaml;
  yaml = pkgs.formats.yaml { };
in
{
  options.programs.lazyvim.yaml = {
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
    programs.lazyvim = {
      extraPackages = [ pkgs.yamlfmt ];
      config.yaml = ./spec.lua;
      treesitterParsers = [ "yaml" ];
    };

    # TODO: Use pkgs.wrapper
    # xdg.configFile."yamlfmt.yaml".source = yaml.generate "yamlfmt.yaml" cfg.settings;
  };
}
