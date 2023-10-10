{ config, lib, pkgs, ... }:

# https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/
# https://kilo.bytesize.xyz/gpu-passthrough-on-nixos
# https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF

let
  inherit (lib) mdDoc mkEnableOption mkIf mkOption types;
  cfg = config.my.vfio;
in
{
  options.my.vfio = {
    enable = mkEnableOption (mdDoc "vfio");

    vfioIds = mkOption {
      type = with types; listOf str;
      default = [ ];
    };

    platform = mkOption {
      type = types.enum [ "amd" "intel" ];
    };

  };

  config = mkIf cfg.enable {
    my.libvirtd.enable = true;

    boot = {
      kernelModules = [
        "kvm-${cfg.platform}"
        "vfio"
        "vfio_iommu_type1"
        "vfio_pci"
        "vfio_virqfd"
      ];

      kernelParams = [
        "${cfg.platform}_iommu=on"
        "${cfg.platform}_iommu=pt"
      ];

      extraModprobeConfig = ''
        options kvm ignore_msrs=1"
        options vfio-pci ids=${builtins.concatStringsSep "," cfg.vfioIds}
      '';
    };

  };
}
