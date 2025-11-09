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

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", ENV{ID_INPUT_JOYSTICK}=="1", ENV{SYSTEMD_USER_WANTS}="evsieve@%s{idVendor}%s{idProduct}-%k.service", TAG+="systemd"
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
