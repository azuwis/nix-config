{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hwheel2swipe;
in

{
  options.services.hwheel2swipe = {
    enable = lib.mkEnableOption "hwheel2swipe";
  };

  config = lib.mkIf cfg.enable {
    hardware.uinput.enable = true;

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{id/vendor}=="045e", ATTRS{id/product}=="0800", ENV{ID_INPUT_MOUSE}=="1", ENV{SYSTEMD_WANTS}+="hwheel2swipe@$kernel.service", TAG+="systemd"
    '';

    systemd.services."hwheel2swipe@" = {
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.hwheel2swipe} /dev/input/%i";
        DynamicUser = true;
        SupplementaryGroups = [
          "input"
          "uinput"
        ];
      };
    };
  };
}
