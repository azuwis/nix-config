{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../openwrt ];

  profile = "netgear_xr500";
}
