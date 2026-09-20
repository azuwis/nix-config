{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.sketchybar;
  # Use the same lua version for sbarlua
  lua = pkgs.sbarlua.luaModule.withPackages (ps: [
    pkgs.sbarlua
    pkgs.rift-lua
  ]);
in

{
  options.services.sketchybar = {
    enhance = lib.mkEnableOption "and enhance sketchybar";
  };

  config = lib.mkIf cfg.enhance (
    lib.mkMerge [
      {
        # launchd.user.agents.sketchybar.serviceConfig = {
        #   StandardErrorPath = "/tmp/sketchybar.log";
        #   StandardOutPath = "/tmp/sketchybar.log";
        # };
        services.sketchybar.enable = true;
        launchd.user.agents.sketchybar.path = lib.mkBefore [ lua ];
        launchd.user.agents.sketchybar.serviceConfig.ProgramArguments = lib.mkAfter [
          "--config"
          "${./config}/sketchybarrc"
        ];
        system.defaults.NSGlobalDomain._HIHideMenuBar = true;
      }

      (lib.mkIf config.services.yabai.enhance {
        services.yabai.config.external_bar = "main:24:0";
      })
    ]
  );
}
