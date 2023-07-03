{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkDefault mkEnableOption mkIf mkMerge;
  cfg = config.my.nvidia;

in
{
  options.my.nvidia = {
    enable = mkEnableOption (mdDoc "nvidia");
    nvidia-patch = mkEnableOption (mdDoc "nvidia-patch") // { default = true; };
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      hm.my.nvidia.enable = true;

      boot.loader.grub.gfxmodeEfi = mkDefault "1920x1080";
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

    (mkIf cfg.nvidia-patch (
      let
        rev = "fbf79521a766a86658a1ee6dd69bcb4bb15beae7";
        hash = "sha256-qto+sp+4irspmNr76Ks90CdyXQw+GrgNeaZsX1E8ztM=";
        nvidia-patch = pkgs.nvidia-patch rev hash;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      in
      {
        hardware.nvidia.package = nvidia-patch.patch-nvenc (nvidia-patch.patch-fbc package);
      }
    ))

  ]);
}
