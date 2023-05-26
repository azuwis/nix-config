{ config, lib, pkgs, ... }:

let
  # ifaces = builtins.attrNames config.networking.interfaces;
  # ens = builtins.filter (name: (builtins.match "^e.*" name) != null) ifaces;
  # en = if ens != [] then builtins.elemAt ens 0 else null;
  config = pkgs.substituteAll {
    src = ./config.yml;
    name = "yambar.yml";
    scripts = ./scripts;
  };
in

{
  home.packages = [ pkgs.yambar ];

  wayland.windowManager.sway.config = {
    bars = [];
    startup = [{
      command = "yambar --config=${config} --log-level=error";
    }];
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
}
