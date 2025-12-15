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
    dualsense = lib.mkEnableOption "evsieve for dualsense";
    mskb = lib.mkEnableOption "evsieve for MS keyboard";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = [ pkgs.evsieve ];
        hardware.uinput.enable = true;
      }

      (lib.mkIf cfg.dualsense {
        hardware.steam-hardware.enable = true;
        users.users.${config.my.user}.extraGroups = [ "uinput" ];

        # To match both bluetooth and usb connected DualSense controller joystick events, need to use `id/vendor` `id/product` here,
        # since none of the parent devices of bluetooth event has `idVendor` `idProduct`
        # Also exclude `*virtual*` devices created by Sunshine
        services.udev.extraRules = ''
          ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{id/vendor}=="054c", ATTRS{id/product}=="0ce6", ATTRS{name}!="*virtual*", ENV{ID_INPUT_JOYSTICK}=="1", ENV{SYSTEMD_USER_WANTS}+="evsieve@%s{id/vendor}%s{id/product}-%k.service", TAG+="systemd"
        '';

        systemd.user.services."evsieve@" = {
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          wants = [ "graphical-session.target" ];
          # Remove `Environment="PATH=..."`, so PATH imported by `systemctl --user import-environment` will be used
          path = lib.mkForce [ ];
          serviceConfig = {
            ExecStart = "${./evsieve.sh} %i";
            SyslogIdentifier = "evsieve";
          };
        };
      })

      (lib.mkIf cfg.mskb {
        services.udev.extraRules = ''
          ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{id/vendor}=="045e", ATTRS{id/product}=="0800", ENV{ID_INPUT_MOUSE}=="1", ENV{SYSTEMD_WANTS}+="evsieve@$attr{id/vendor}$attr{id/product}-$kernel.service", TAG+="systemd"
        '';

        systemd.services."evsieve@" = {
          path = with pkgs; [
            bash
            evsieve
          ];
          serviceConfig = {
            ExecStart = "${./evsieve.sh} %i";
            DynamicUser = true;
            SupplementaryGroups = [
              "input"
              "uinput"
            ];
            SyslogIdentifier = "evsieve";
          };
        };
      })

    ]
  );
}
