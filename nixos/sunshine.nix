{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib

then

{
  home.packages = [ pkgs.sunshine ];

  xdg.configFile."sunshine/sunshine.conf".text = ''
    capture = wlr
    channels = 2
    fps = [30,60]
    origin_web_ui_allowed = pc
    resolutions = [
        1280x720,
        1920x1080
    ]
  '';

  systemd.user.services.sunshine = {
    Install.WantedBy = [ "default.target" ];
    Service = {
      Environment = [
        "PATH=/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin"
        "LIBSEAT_BACKEND=builtin"
        "SEATD_VTBOUND=0"
        "WLR_BACKENDS=headless,libinput"
        "WLR_LIBINPUT_NO_DEVICES=1"
        "DBUS_SESSION_BUS_ADDRESS="
      ];
      ExecStartPre =
        let
          prestart = pkgs.writeShellScriptBin "sunshine-prestart" ''
            {
            grep -Ev '(^exec swaylock|^exec swayidle|events disabled)' ${config.xdg.configHome}/sway/config
            echo '
            output HEADLESS-1 mode 1920x1080@60Hz
            seat seat0 fallback false
            seat seat0 attach "48879:57005:Keyboard_passthrough"
            seat seat0 attach "48879:57005:Touchscreen_passthrough"
            seat seat0 attach "1133:16440:Logitech_Wireless_Mouse_PID:4038"
            exec sunshine
            '
            } > ${config.xdg.cacheHome}/sway-sunshine
          '';
        in "${prestart}/bin/sunshine-prestart";
      ExecStart = "/etc/profiles/per-user/%u/bin/sway -c ${config.xdg.cacheHome}/sway-sunshine";
      Restart = "on-failure";
    };
  };

  wayland.windowManager.sway.extraConfig = ''
    input "48879:57005:Keyboard_passthrough" events disabled
    input "48879:57005:Touchscreen_passthrough" events disabled
    input "1133:16440:Logitech_Wireless_Mouse_PID:4038" events disabled
  '';
}

else

{
  hardware.uinput.enable = true;
  users.users.${config.my.user}.extraGroups = [ "uinput" ];
  services.udev.extraRules = ''
    SUBSYSTEMS=="input", ATTRS{id/product}=="4038", ATTRS{id/vendor}=="046d", ATTRS{name}=="Logitech Wireless Mouse PID:4038", OWNER="${config.my.user}"
    SUBSYSTEMS=="input", ATTRS{id/product}=="dead", ATTRS{id/vendor}=="beef", ATTRS{name}=="Touchscreen passthrough", OWNER="${config.my.user}"
    SUBSYSTEMS=="input", ATTRS{id/product}=="dead", ATTRS{id/vendor}=="beef", ATTRS{name}=="Keyboard passthrough", OWNER="${config.my.user}"
    SUBSYSTEMS=="input", ATTRS{id/product}=="028e", ATTRS{id/vendor}=="045e", ATTRS{name}=="Microsoft X-Box 360 pad", OWNER="${config.my.user}"
  '';

  # services.seatd.enable = true;
  # users.users.${config.my.user}.extraGroups = [ seatd" ];

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
  #   TAG=="seat", SUBSYSTEMS=="drm", KERNELS=="card0", KERNEL=="card0-HDMI-A-2", ENV{ID_SEAT}="seat-sunshine"
  #   SUBSYSTEMS=="input", ATTR{id/product}=="4038", ATTR{id/vendor}=="046d", ATTR{name}=="Logitech Wireless Mouse PID:4038", TAG+="seat", TAG+="seat-sunshine", ENV{ID_SEAT}="seat-sunshine"
  #   SUBSYSTEMS=="input", ATTR{id/product}=="dead", ATTR{id/vendor}=="beef", ATTR{name}=="Touchscreen passthrough", TAG+="seat", TAG+="seat-sunshine", ENV{ID_SEAT}="seat-sunshine"
  #   SUBSYSTEMS=="input", ATTR{id/product}=="dead", ATTR{id/vendor}=="beef", ATTR{name}=="Keyboard passthrough", TAG+="seat", TAG+="seat-sunshine", ENV{ID_SEAT}="seat-sunshine"
  # '';

  # security.wrappers.sunshine = {
  #   owner = "root";
  #   group = "root";
  #   capabilities = "cap_sys_admin+p";
  #   source = "${pkgs.sunshine}/bin/sunshine";
  # };

  networking.firewall = {
    allowedTCPPorts = [ 47984 47989 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      { from = 48002; to = 48010; }
    ];
  };
}
