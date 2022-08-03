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

  systemd.user.services.yambar = {
    Unit = {
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.yambar}/bin/yambar --config=${config} --log-level=error";
      Environment = "PATH=${pkgs.coreutils-full}/bin";
      Restart = "on-failure";
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  wayland.windowManager.sway.config.bars = [];
}
