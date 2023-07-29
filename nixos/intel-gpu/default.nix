{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.intelGpu;

in
{
  options.my.intelGpu = {
    enable = mkEnableOption (mdDoc "intelGpu");
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.intel-gpu-tools ];

    security.wrappers.intel_gpu_top = {
      source = "${pkgs.intel-gpu-tools}/bin/intel_gpu_top";
      owner = "root";
      group = "wheel";
      permissions = "0750";
      capabilities = "cap_perfmon=ep";
    };

    hardware.opengl.extraPackages = [ pkgs.intel-vaapi-driver ];
  };
}
