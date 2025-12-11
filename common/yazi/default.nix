{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.yazi;
in

{
  options.programs.yazi = {
    enhance = lib.mkEnableOption "and enhance yazi";
  };

  config = lib.mkIf cfg.enhance {
    programs.yazi.enable = true;
    programs.yazi.package = pkgs.yazi.override {
      optionalDeps = [ ];
    };
    programs.yazi.settings = {
      yazi = {
        mgr.ratio = [
          1
          3
          4
        ];
        preview = {
          cache_dir = "~/.cache/yazi";
          max_height = 1200;
          max_width = 800;
        };
      };
    };
  };
}
