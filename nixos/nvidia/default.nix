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
    package = mkPackageOption config.boot.kernelPackages.nvidiaPackages "latest" { };
    firefox-fix = mkEnableOption "nvidia firefox fix";
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
    }

    (mkIf (cfg.firefox-fix && config.programs.firefox.enable) {
      # https://github.com/elFarto/nvidia-vaapi-driver
      programs.firefox.env.GDK_BACKEND = null;
      programs.firefox.env.MOZ_DISABLE_RDD_SANDBOX = "1";
      programs.firefox.settings = {
        "widget.dmabuf.force-enabled" = true;
      };
    })

    (mkIf cfg.nvidia-patch {
      hardware.nvidia.package = cfg.package.overrideAttrs (old: {
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
    })

    (mkIf (cfg.sway-fix && config.programs.sway.enable) {
      # Sway complains even nvidia GPU is only used for offload
      programs.sway.extraOptions = [ "--unsupported-gpu" ];
      # export WLR_RENDERER=vulkan
      programs.sway.extraSessionCommands = ''
        export WLR_NO_HARDWARE_CURSORS=1
      '';
    })
  ]);
}
