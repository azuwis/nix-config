{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.pn532;
in
{
  options.my.pn532 = {
    enable = mkEnableOption "pn532";
  };

  config = mkIf cfg.enable {
    users.users.${config.my.user}.extraGroups = [ "dialout" ];

    environment.systemPackages = with pkgs; [ mfoc-hardnested ];

    environment.etc."nfc/libnfc.conf".text = ''
      device.name = "pn532"
      device.connstring = "pn532_uart:/dev/ttyUSB0"
    '';
  };
}
