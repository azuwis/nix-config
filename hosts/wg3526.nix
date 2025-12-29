{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../openwrt ];

  profile = "zbtlink_zbt-wg3526-16m";
}
