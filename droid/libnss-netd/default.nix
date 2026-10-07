{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.libnss-netd;
in

{
  options.services.libnss-netd = {
    enable = lib.mkEnableOption "libnss-netd";
  };

  config = lib.mkIf cfg.enable {
    environment.etc."nsswitch.conf".text = ''
      hosts: files netd [NOTFOUND=return] dns
    '';

    environment.etc."ld-nix.so.preload".text = ''
      ${pkgs.libnss-netd}/lib/nss-hosts-shim.so
      ${pkgs.libnss-netd}/lib/libnss_netd.so.2
    '';
  };
}
