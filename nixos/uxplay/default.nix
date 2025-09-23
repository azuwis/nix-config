{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.uxplay;
in
{
  options.programs.uxplay = {
    enable = lib.mkEnableOption "uxplay";

    args = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "-nohold"
        "-vd"
        "vah264dec"
      ];
    };

    package = lib.mkPackageOption pkgs "uxplay" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = cfg.package;

    networking.firewall.allowedTCPPorts = [
      7100
      7000
      7001
    ];
    networking.firewall.allowedUDPPorts = [
      6000
      6001
      7011
    ];

    programs.sway.extraConfig = ''
      for_window [instance="^UxPlay@"] fullscreen enable
    '';

    programs.wayland.startup.uxplay = [
      "uxplay"
      "-p"
    ]
    ++ cfg.args;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish.enable = true;
      publish.userServices = true;
    };
  };
}
