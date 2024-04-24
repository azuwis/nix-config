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
      SUBSYSTEMS=="input", ATTRS{id/product}=="4038", ATTRS{id/vendor}=="046d", ATTRS{name}=="Logitech Wireless Mouse PID:4038", OWNER="${cfg.user}"
      SUBSYSTEMS=="input", ATTRS{id/product}=="dead", ATTRS{id/vendor}=="beef", ATTRS{name}=="Touchscreen passthrough", OWNER="${cfg.user}"
      SUBSYSTEMS=="input", ATTRS{id/product}=="dead", ATTRS{id/vendor}=="beef", ATTRS{name}=="Keyboard passthrough", OWNER="${cfg.user}"
      SUBSYSTEMS=="input", ATTRS{id/product}=="028e", ATTRS{id/vendor}=="045e", ATTRS{name}=="Microsoft X-Box 360 pad", OWNER="${cfg.user}"
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
