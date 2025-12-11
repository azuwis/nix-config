{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.foot;
in

{
  options.programs.foot = {
    enhance = lib.mkEnableOption "and enhance foot";
  };

  config = lib.mkIf cfg.enhance (
    lib.mkMerge [
      {
        programs.wayland.startup.foot = [
          "foot"
          "--server"
        ];
        programs.wayland.terminal = "footclient";

        environment.systemPackages = [
          (pkgs.writeShellScriptBin "tmenu" ''
            ${config.programs.foot.package}/bin/foot --app-id tmenu --window-size-chars 50x10 "$@"
          '')
        ];

        programs.foot = {
          enable = true;
          settings = {
            main = {
              font = lib.mkDefault "monospace:pixelsize=20";
              term = "xterm-256color";
            };
          };
          theme = "nord";
        };
      }
    ]
  );
}
