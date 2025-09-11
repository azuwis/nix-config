{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkMerge;
  cfg = config.programs.foot;
in

{
  config = mkIf cfg.enable (mkMerge [
    {
      my.wayland.startup.foot = [
        "foot"
        "--server"
      ];
      my.wayland.terminal = "footclient";

      environment.systemPackages = [
        (pkgs.writeShellScriptBin "tmenu" ''
          ${config.programs.foot.package}/bin/foot --app-id tmenu --window-size-chars 50x10 "$@"
        '')
      ];

      programs.foot = {
        settings = {
          main = {
            font = lib.mkDefault "monospace:pixelsize=20";
            term = "xterm-256color";
          };
        };
        theme = "nord";
      };
    }

    (mkIf config.my.sway.enable {
      hm.wayland.windowManager.sway.config = {
        startup = [ { command = "foot --server"; } ];
      };
    })
  ]);
}
