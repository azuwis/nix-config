{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.my.foot;
in
{
  options.my.foot = {
    enable = mkEnableOption "foot";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      my.wayland.terminal = "footclient";

      home.packages = [
        (pkgs.writeScriptBin "tmenu" ''
          ${config.programs.foot.package}/bin/foot --app-id tmenu --window-size-chars 50x10 "$@"
        '')
      ];

      programs.foot = {
        enable = true;
        settings = {
          main = {
            font = lib.mkDefault "monospace:pixelsize=20";
            include = "${lib.getOutput "themes" pkgs.foot}/share/foot/themes/nord";
            term = "xterm-256color";
          };
        };
      };
    }

    (mkIf config.my.sway.enable {
      wayland.windowManager.sway.config = {
        startup = [ { command = "foot --server --log-level=error"; } ];
      };
    })
  ]);
}
