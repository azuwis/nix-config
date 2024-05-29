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

    services.udev.extraRules = ''
      SUBSYSTEM=="misc", KERNEL=="uhid", GROUP="uinput", MODE="0660"
      SUBSYSTEMS=="input", ATTRS{id/vendor}=="045e", ATTRS{id/product}=="028e", ATTRS{name}=="Microsoft X-Box 360 pad", OWNER="${cfg.user}"
      SUBSYSTEMS=="input", ATTRS{id/vendor}=="045e", ATTRS{id/product}=="02ea", ATTRS{name}=="Wolf X-Box One (virtual) pad", OWNER="${cfg.user}"
      SUBSYSTEMS=="input", ATTRS{id/vendor}=="046d", ATTRS{id/product}=="4038", ATTRS{name}=="Logitech Wireless Mouse PID:4038", OWNER="${cfg.user}"
      SUBSYSTEMS=="input", ATTRS{id/vendor}=="054c", ATTRS{id/product}=="0ce6", ATTRS{name}=="Wolf DualSense (virtual) pad", OWNER="${cfg.user}"
      SUBSYSTEMS=="input", ATTRS{id/vendor}=="057e", ATTRS{id/product}=="2009", ATTRS{name}=="Wolf Nintendo (virtual) pad", OWNER="${cfg.user}"
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
