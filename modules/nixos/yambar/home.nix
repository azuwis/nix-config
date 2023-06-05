{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.yambar;
  # ifaces = builtins.attrNames config.networking.interfaces;
  # ens = builtins.filter (name: (builtins.match "^e.*" name) != null) ifaces;
  # en = if ens != [] then builtins.elemAt ens 0 else null;
  configFile = pkgs.substituteAll {
    src = ./config.yml;
    name = "yambar.yml";
    scripts = ./scripts;
  };

in {
  options.my.yambar = {
    enable = mkEnableOption (mdDoc "yambar");
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.yambar ];

    xdg.configFile."yambar/config.yml".source = configFile;

    wayland.windowManager.sway.config = {
      bars = [];
      startup = [{ command = "yambar --log-level=error"; }];
    };

    # systemd.user.services.yambar = {
    #   Unit = {
    #     PartOf = [ "graphical-session.target" ];
    #     After = [ "graphical-session.target" ];
    #   };
    #
    #   Service = {
    #     ExecStart = "${pkgs.yambar}/bin/yambar --config=${config} --log-level=error";
    #     Environment = "PATH=/run/current-system/sw/bin";
    #     Restart = "on-failure";
    #   };
    #
    #   Install = { WantedBy = [ "graphical-session.target" ]; };
    # };

  };
}
