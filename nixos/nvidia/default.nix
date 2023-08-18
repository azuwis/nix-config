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

      boot.loader.grub.gfxmodeEfi = mkDefault "1920x1080";
      hardware.nvidia.modesetting.enable = true;
      services.xserver.videoDrivers = [ "nvidia" ];

      # Sway
      # sway/wlroots vulkan need vulkan-validation-layers for now, may remove on later version.
      # https://gitlab.freedesktop.org/wlroots/wlroots/-/merge_requests/3850
      environment.systemPackages = [ pkgs.vulkan-validation-layers ];
      programs.sway = {
        extraOptions = [ "--unsupported-gpu" ];
        extraSessionCommands = ''
          export WLR_NO_HARDWARE_CURSORS=1
          # export WLR_RENDERER=vulkan
        '';
      };

      # Firefox
      # https://github.com/elFarto/nvidia-vaapi-driver
      hardware.opengl.extraPackages = [ pkgs.nvidia-vaapi-driver ];
      hm.my.firefox.env = [ "MOZ_DISABLE_RDD_SANDBOX=1" ];
      hm.programs.firefox.profiles.default.settings = {
        "widget.dmabuf.force-enabled" = true;
      };

    })

    (mkIf cfg.nvidia-patch (
      let
        rev = "1100fc888d41e89759a90fe92eb4148d4a9c506b";
        hash = "sha256-7M7I5ebT5CW0DK4UkBVSSRnXDmE/sdD1rpAhNnIYLlk=";
        nvidia-patch = pkgs.nvidia-patch rev hash;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      in
      {
        hardware.nvidia.package = nvidia-patch.patch-nvenc (nvidia-patch.patch-fbc package);
      }
    ))

  ]);
}
