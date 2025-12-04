{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Use the same lua version for sbarlua
  lua = pkgs.sbarlua.luaModule.withPackages (ps: [ pkgs.sbarlua ]);
in

{
  # launchd.user.agents.sketchybar.serviceConfig = {
  #   StandardErrorPath = "/tmp/sketchybar.log";
  #   StandardOutPath = "/tmp/sketchybar.log";
  # };
  services.sketchybar.enable = true;
  launchd.user.agents.sketchybar.path = lib.mkForce [
    lua
    config.my.systemPath
  ];
  launchd.user.agents.sketchybar.serviceConfig.ProgramArguments = lib.mkAfter [
    "--config"
    "${./config}/sketchybarrc"
  ];
  services.yabai.config.external_bar = "main:24:0";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
