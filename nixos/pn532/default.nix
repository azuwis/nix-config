{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.pn532;
in
{
  options.my.pn532 = {
    enable = mkEnableOption (mdDoc "pn532");
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mfoc-hardnested
    ];

    environment.etc."nfc/libnfc.conf".text = ''
      device.name = "pn532"
      device.connstring = "pn532_uart:/dev/ttyUSB0"
    '';
  };
}
