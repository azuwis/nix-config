{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.firefox;
in
{
  options.my.firefox = {
    enable = mkEnableOption "firefox";
  };

  config = mkIf cfg.enable {
    hm.my.firefox.enable = true;

    homebrew.casks = [ "firefox" ];
  };
}
