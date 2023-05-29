{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib

then

{
  home.packages = [ pkgs.sunshine ];

  systemd.user.services.sunshine = {
    Unit.After = "network.target";
    Install.WantedBy = [ "multi-user.target" ];
    Service = {
      Environment = [
        "PATH=/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin"
        "WLR_BACKENDS=headless,libinput"
      ];
      ExecStartPre =
        let
          prestart = pkgs.writeShellScriptBin "sunshine-prestart" ''
            {
            grep -Ev '(^exec swaylock|events disabled)' ${config.xdg.configHome}/sway/config
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
  users.users.${config.my.user}.extraGroups = [ "input" "uinput" ];
  services.udev.extraRules = ''
    KERNEL=="tty0", SUBSYSTEM=="tty", OWNER="azuwis"
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
  # udevadm info --attribute-walk --path=/sys/device/...
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
