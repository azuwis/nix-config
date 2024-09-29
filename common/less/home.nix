{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.less;
in
{
  options.my.less = {
    enable = mkEnableOption "less";
  };

  config = mkIf cfg.enable {
    programs.less = {
      enable = true;
      keys = ''
        #env
        LESS = --RAW-CONTROL-CHARS --no-init --quit-if-one-screen --shift 5
      '';
    };
  };
}
