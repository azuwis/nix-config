{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zramSwap;
in
{
  options.zramSwap = {
    enhance = lib.mkEnableOption "and enhance zram swap";
  };

  config = lib.mkIf cfg.enhance {
    # boot.kernel.sysctl."vm.swappiness" = 100;
  };
}
