{ config, lib, pkgs, ... }:

{
  zramSwap.enable = true;
  boot.kernel.sysctl."vm.swappiness" = 100;
}
