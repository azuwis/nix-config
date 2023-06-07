{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkMerge;
  cfg = config.my.nvidia;

in {
  options.my.nvidia = {
    enable = mkEnableOption (mdDoc "nvidia");
    nvidia-patch = mkEnableOption (mdDoc "nvidia-patch") // { default = true; };
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      hm.my.nvidia.enable = true;

      hardware.nvidia.modesetting.enable = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      programs.sway = {
        extraOptions = [ "--unsupported-gpu" ];
        extraSessionCommands = ''
          export WLR_NO_HARDWARE_CURSORS=1
          export WLR_RENDERER=vulkan
        '';
      };
    })

    (mkIf cfg.nvidia-patch (let
      rev = "b240ee53ac2f9035ee810b7f9b0b455b3876086f";
      hash = "sha256-VY0XtLc0jfqoeSLD5l90tCoKpcHBkpmgNNKH6bmnVc4=";
      nvidia-patch = pkgs.nvidia-patch rev hash;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    in {
      hardware.nvidia.package = nvidia-patch.patch-nvenc (nvidia-patch.patch-fbc package);
    }))

  ]);
}
