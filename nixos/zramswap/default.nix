{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.zramswap;

in
{
  options.my.zramswap = {
    enable = mkEnableOption (mdDoc "zramswap");
  };

  config = mkIf cfg.enable {
    zramSwap.enable = true;
    boot.kernel.sysctl."vm.swappiness" = 100;
  };
}
