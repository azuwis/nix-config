{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.my.sunshine;
in
{
  options.my.sunshine = {
    enable = mkEnableOption "sunshine";
    openFirewall = mkEnableOption "openFirewall" // {
      default = true;
    };
    user = mkOption {
      type = types.str;
      default = config.my.user;
    };
  };

  config = mkIf cfg.enable {
    hm.my.sunshine.enable = true;

    hardware.uinput.enable = true;
    users.users.${cfg.user}.extraGroups = [ "uinput" ];

    boot.kernelModules = [ "uhid" ];

    # https://github.com/LizardByte/Sunshine/blob/master/src_assets/linux/misc/60-sunshine.rules
    # KERNEL=="hidraw*", ATTRS{name}=="Sunshine PS5 (virtual) pad", OWNER="${cfg.user}"
    services.udev.extraRules = ''
      SUBSYSTEM=="misc", KERNEL=="uhid", GROUP="uinput", MODE="0660"
      SUBSYSTEMS=="input", ATTRS{name}=="Sunshine * (virtual) pad*", OWNER="${cfg.user}"
      SUBSYSTEMS=="input", ATTRS{id/vendor}=="ab00", ATTRS{id/product}=="ab0*", ATTRS{name}=="Wolf *", OWNER="${cfg.user}"
      SUBSYSTEMS=="input", ATTRS{id/vendor}=="beef", ATTRS{id/product}=="dead", ATTRS{name}=="* passthrough", OWNER="${cfg.user}"
    '';

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        47984
        47989
        48010
      ];
      allowedUDPPortRanges = [
        {
          from = 47998;
          to = 48000;
        }
        {
          from = 48002;
          to = 48010;
        }
      ];
    };

    # swaymsg -s /run/user/*/sway-ipc.*.sock --pretty --type get_inputs | awk '/Identifier:/ {print $2}'
    my.sway.extraConfig = ''
      input "1356:3302:Sunshine_DualSense_(virtual)_pad_Touchpad" events disabled
      input "43776:43778:Wolf_mouse_(abs)_virtual_device" events disabled
      input "48879:57005:Keyboard_passthrough" events disabled
      input "48879:57005:Mouse_passthrough" events disabled
      input "48879:57005:Pen_passthrough" events disabled
      input "48879:57005:Touch_passthrough" events disabled
    '';

    # services.seatd.enable = true;
    # users.users.${cfg.user}.extraGroups = [ "seatd" ];

    # environment.systemPackages = [ pkgs.seatd ];
    # security.wrappers.seatd-launch = {
    #   owner = "root";
    #   group = "root";
    #   source = "${pkgs.seatd}/bin/seatd-launch";
    # };

    # loginctl seat-status seat0
    # udevadm info -a [/sys/device/...|/dev/...]
    # udevadm monitor --environment --property --udev
    # services.udev.extraRules = ''
    #   TAG=="seat", SUBSYSTEMS=="drm", KERNELS=="card0", KERNEL=="card0-DP-1", ENV{ID_SEAT}="seat-sunshine"
    #   SUBSYSTEMS=="input", ATTRS{id/product}=="4038", ATTRS{id/vendor}=="046d", ATTRS{name}=="Logitech Wireless Mouse PID:4038", TAG+="seat", TAG+="seat-sunshine", ENV{ID_SEAT}="seat-sunshine"
    #   SUBSYSTEMS=="input", ATTRS{id/product}=="dead", ATTRS{id/vendor}=="beef", ATTRS{name}=="Touchscreen passthrough", TAG+="seat", TAG+="seat-sunshine", ENV{ID_SEAT}="seat-sunshine"
    #   SUBSYSTEMS=="input", ATTRS{id/product}=="dead", ATTRS{id/vendor}=="beef", ATTRS{name}=="Keyboard passthrough", TAG+="seat", TAG+="seat-sunshine", ENV{ID_SEAT}="seat-sunshine"
    #   SUBSYSTEMS=="input", ATTRS{id/product}=="028e", ATTRS{id/vendor}=="045e", ATTRS{name}=="Microsoft X-Box 360 pad", TAG+="seat", TAG+="seat-sunshine", ENV{ID_SEAT}="seat-sunshine"
    # '';
  };
}
