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
  config = lib.mkIf cfg.enable {
    # boot.kernel.sysctl."vm.swappiness" = 100;
  };
}
