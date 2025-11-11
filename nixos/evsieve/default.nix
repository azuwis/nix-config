{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.evsieve;
in

{
  options.services.evsieve = {
    enable = lib.mkEnableOption "evsieve";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.evsieve ];

    hardware.steam-hardware.enable = true;
    hardware.uinput.enable = true;
    users.users.${config.my.user}.extraGroups = [ "uinput" ];

    # To match both bluetooth and usb connected DualSense controller joystick events, need to use `id/vendor` `id/product` here,
    # since none of the parent devices of bluetooth event has `idVendor` `idProduct`
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{id/vendor}=="054c", ATTRS{id/product}=="0ce6", ENV{ID_INPUT_JOYSTICK}=="1", ENV{SYSTEMD_USER_WANTS}+="evsieve@%s{id/vendor}%s{id/product}-%k.service", TAG+="systemd"
    '';

    systemd.user.services."evsieve@" = {
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      serviceConfig = {
        # Use `/bin/sh --login` to make the ENV close to desktop
        ExecStart = ''/bin/sh --login -c "exec ${./evsieve.sh} %i"'';
        SyslogIdentifier = "evsieve";
      };
    };
  };
}
