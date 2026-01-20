{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../openwrt ];

  builder.profile = "netgear_xr500";
  uci.system.hostname = "xr500";
}
