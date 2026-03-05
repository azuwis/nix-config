{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.scinet;
in

{
  options.scinet = {
    enable = lib.mkEnableOption "scinet";
  };

  config = lib.mkIf cfg.enable {
    builder.packages = [ "shadowsocks-libev-ss-rules" ];

    sdk.enable = true;
    sdk.packages = [ "shadowsocks-libev" ];
  };
}
