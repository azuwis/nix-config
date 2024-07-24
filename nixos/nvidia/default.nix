{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkPackageOption
    ;
  cfg = config.my.nvidia;
in
{
  options.my.nvidia = {
    enable = mkEnableOption "nvidia";
    package = mkPackageOption config.boot.kernelPackages.nvidiaPackages "production" { };
    firefox-fix = mkEnableOption "nvidia firefox fix" // {
      default = true;
    };
    nvidia-patch = mkEnableOption "nvidia-patch";
    sway-fix = mkEnableOption "nvidia sway fix" // {
      default = true;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      boot.loader.grub.gfxmodeEfi = mkDefault "1920x1080";
      hardware.nvidia.modesetting.enable = true;
      hardware.nvidia.package = cfg.package;
      # hardware.nvidia.prime = {
      #   intelBusId = "PCI:0:2:0";
      #   nvidiaBusId = "PCI:1:0:0";
      #   offload.enable = true;
      #   offload.enableOffloadCmd = true;
      # };
      services.xserver.videoDrivers = [ "nvidia" ];

      # Sway complains even nvidia GPU is only used for offload
      programs.sway.extraOptions = [ "--unsupported-gpu" ];
    }

    (mkIf cfg.firefox-fix {
      # https://github.com/elFarto/nvidia-vaapi-driver
      hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];
      hm.my.firefox.env.GDK_BACKEND = null;
      hm.my.firefox.env.MOZ_DISABLE_RDD_SANDBOX = "1";
      hm.programs.firefox.profiles.default.settings = {
        "widget.dmabuf.force-enabled" = true;
      };
    })

    (mkIf cfg.nvidia-patch {
      hardware.nvidia.package = cfg.package.overrideAttrs (old: {
        preFixup =
          (old.preFixup or "")
          + ''
            patch_nvidia() {
              local patch_file patch_sed so_file
              patch_file=$1
              so_file=$2
              patch_sed=$(grep -m 1 -F '"${old.version}"' "${inputs.nvidia-patch}/$patch_file" | cut -d "'" -f 2)
              echo "patching $so_file with $patch_sed"
              sed -i "$patch_sed" "$out/lib/$so_file"
            }
            patch_nvidia patch.sh libnvidia-encode.so
            patch_nvidia patch-fbc.sh libnvidia-fbc.so
          '';
      });
    })

    (mkIf cfg.sway-fix {
      # sway/wlroots vulkan need vulkan-validation-layers for now, may remove on later version.
      # https://gitlab.freedesktop.org/wlroots/wlroots/-/merge_requests/3850
      environment.systemPackages = [ pkgs.vulkan-validation-layers ];
      # export WLR_RENDERER=vulkan
      programs.sway.extraSessionCommands = ''
        export WLR_NO_HARDWARE_CURSORS=1
      '';
    })
  ]);
}
