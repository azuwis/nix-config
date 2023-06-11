{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.nvidia;

in {
  options.my.nvidia = {
    enable = mkEnableOption (mdDoc "nvidia");
  };

  config = mkIf cfg.enable {
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
