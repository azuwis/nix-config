{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.jujutsu;
in
{
  options.my.jujutsu = {
    enable = mkEnableOption "jujutsu";
  };

  config = mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        colors = {
          "diff removed token" = {
            underline = false;
          };
          "diff added token" = {
            underline = false;
          };
        };
        ui.default-command = "status";
        user = {
          inherit (config.my) email name;
        };
      };
    };
  };
}
