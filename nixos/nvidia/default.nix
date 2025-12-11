{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.nvidia;
in
{
  options.hardware.nvidia = {
    enhance = lib.mkEnableOption "nvidia";
    firefox-fix = lib.mkEnableOption "nvidia firefox fix";
    sway-fix = lib.mkEnableOption "nvidia sway fix";
  };

  config = lib.mkIf cfg.enhance (
    lib.mkMerge [
      {
        boot.loader.grub.gfxmodeEfi = lib.mkDefault "1920x1080";
        hardware.nvidia.modesetting.enable = true;
        # Only install nvidia-vaapi-driver if firefox-fix, but not by default,
        # specifically designed to be used by Firefox
        hardware.nvidia.videoAcceleration = lib.mkOverride 999 false;
        # hardware.nvidia.prime = {
        #   intelBusId = "PCI:0:2:0";
        #   nvidiaBusId = "PCI:1:0:0";
        #   offload.enable = true;
        #   offload.enableOffloadCmd = true;
        # };
        services.xserver.videoDrivers = [ "nvidia" ];

        # hardware.nvidia.package = config.lib.nvidia.patch config.boot.kernelPackages.nvidiaPackages.stable;
        lib.nvidia.patch =
          package:
          package.overrideAttrs (old: {
            preFixup = (old.preFixup or "") + ''
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
      }

      (lib.mkIf (cfg.firefox-fix && config.programs.firefox.enable) {
        # https://github.com/elFarto/nvidia-vaapi-driver
        hardware.nvidia.videoAcceleration = true;
        programs.firefox.env.GDK_BACKEND = null;
        programs.firefox.env.MOZ_DISABLE_RDD_SANDBOX = "1";
        programs.firefox.settings = {
          "widget.dmabuf.force-enabled" = true;
        };
      })

      (lib.mkIf (cfg.sway-fix && config.programs.sway.enable) {
        # export WLR_RENDERER=vulkan
        programs.sway.extraSessionCommands = ''
          export WLR_NO_HARDWARE_CURSORS=1
        '';
      })
    ]
  );
}
