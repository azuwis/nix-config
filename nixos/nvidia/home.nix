{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.nvidia;

in {
  options.my.nvidia = {
    enable = mkEnableOption (mdDoc "nvidia");
  };

  config = mkIf cfg.enable {
    # sway/wlroots vulkan need vulkan-validation-layers for now, may remove on later version.
    # https://gitlab.freedesktop.org/wlroots/wlroots/-/merge_requests/3850
    home.packages = [ pkgs.vulkan-validation-layers ];

    wayland.windowManager.sway = {
      extraOptions = [ "--unsupported-gpu" ];
      extraSessionCommands = ''
      export WLR_NO_HARDWARE_CURSORS=1
      export WLR_RENDERER=vulkan
      '';
    };
  };
}
