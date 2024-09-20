{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkPackageOption
    ;
  cfg = config.my.niri;
in
{
  options.my.niri = {
    enable = mkEnableOption "niri";
    package = mkPackageOption pkgs "niri" { };
  };

  config = mkIf cfg.enable (mkMerge [
    (import "${modulesPath}/programs/wayland/wayland-session.nix" {
      inherit lib;
    })

    {
      hm.my.niri.enable = true;
      # my.wayland.session = "niri-session";

      environment.systemPackages = with pkgs; [
        niri
        xwayland-satellite
      ];

      systemd.packages = [ cfg.package ];

      xdg.portal = {
        enable = true;
        # For screen capture
        # extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
        configPackages = [ cfg.package ];
      };
    }
  ]);
}
