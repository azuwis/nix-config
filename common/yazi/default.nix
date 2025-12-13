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
    restore = lib.mkEnableOption "yazi restore plugin";
  };

  config = lib.mkIf cfg.enhance {
    programs.yazi.enable = true;
    programs.yazi.package = pkgs.yazi.override {
      extraPackages = lib.optionals cfg.restore [ pkgs.trash-cli ];
      optionalDeps = [ ];
    };
    programs.yazi.settings = {
      keymap = {
        mgr = {
          prepend_keymap = lib.optionals cfg.restore [
            {
              on = "u";
              run = "plugin restore -- --interactive --interactive-overwrite";
              desc = "Restore deleted files/folders (Interactive overwrite)";
            }
          ];
        };
      };
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
    programs.yazi.plugins = lib.optionalAttrs cfg.restore { inherit (pkgs.yaziPlugins) restore; };
  };
}
