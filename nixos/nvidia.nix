{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib

then

lib.mkIf config.wayland.windowManager.sway.enable

{
  wayland.windowManager.sway = {
    extraOptions = [ "--unsupported-gpu" ];
    extraSessionCommands = ''
      export WLR_NO_HARDWARE_CURSORS=1
    '';
  };
}

else

lib.mkMerge [
  (let
    rev = "b240ee53ac2f9035ee810b7f9b0b455b3876086f";
    hash = "sha256-VY0XtLc0jfqoeSLD5l90tCoKpcHBkpmgNNKH6bmnVc4=";
    nvidia-patch = pkgs.nvidia-patch rev hash;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  in {
    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.package = nvidia-patch.patch-nvenc (nvidia-patch.patch-fbc package);
    services.xserver.videoDrivers = [ "nvidia" ];
  })

  (lib.mkIf config.programs.sway.enable {
    programs.sway = {
      extraOptions = [ "--unsupported-gpu" ];
      extraSessionCommands = ''
        export WLR_NO_HARDWARE_CURSORS=1
      '';
    };
  })
]
