{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mskb;
in

{
  options.services.mskb = {
    enable = lib.mkEnableOption "enhancement for Microsoft All-in-One Media Keyboard";
  };

  config = lib.mkIf cfg.enable {
    hardware.uinput.enable = true;

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{id/vendor}=="045e", ATTRS{id/product}=="0800", ENV{ID_INPUT_MOUSE}=="1", MODE="0660", GROUP="uinput", ENV{SYSTEMD_WANTS}+="mskb@$kernel.service", TAG+="systemd"
    '';

    systemd.services."mskb@" = {
      environment = {
        IDLE_TIMEOUT_MS = "350";
        # The pad default to vertical natural scroll, reverse back, so WM's
        # natural-scroll setting works as expected
        SCROLL_RATIO = "-1";
      };
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.wheelswipe} /dev/input/%i";
        DynamicUser = true;
        SupplementaryGroups = [ "uinput" ];
      };
    };
  };
}
