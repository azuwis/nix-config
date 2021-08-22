{ config, lib, pkgs, ... }:

{
  environment.etc."sudoers.d/yabai".text = ''
    ${config.my.user} ALL = (root) NOPASSWD: ${pkgs.yabai}/bin/yabai --load-sa
  '';

  environment.systemPackages = [
    pkgs.websocat
  ];

  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    config = {
      auto_balance = "on";
      layout = "bsp";
      mouse_modifier = "alt";
      window_gap = 1;
      window_shadow = "float";
    };
    extraConfig = ''
      sudo yabai --load-sa
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
      yabai -m rule --add app="System Preferences" manage=off
      for event in space_changed display_changed
      do
        yabai -m signal --add event=$event action='echo \{\"type\":\"WIDGET_WANTS_REFRESH\",\"payload\":\"nibar-spaces-jsx\"\} | websocat -E --origin http://127.0.0.1:41416 ws://127.0.0.1:41416' label=nibar_spaces_$event
      done
      for event in application_front_switched
      do
        yabai -m signal --add event=$event action='echo \{\"type\":\"WIDGET_WANTS_REFRESH\",\"payload\":\"nibar-windows-jsx\"\} | websocat -E --origin http://127.0.0.1:41416 ws://127.0.0.1:41416' label=nibar_windows_$event
      done
      yabai -m space 5 --layout float
    '';
  };

  # launchd.user.agents.yabai.serviceConfig = {
  #   StandardErrorPath = "/tmp/yabai.log";
  #   StandardOutPath = "/tmp/yabai.log";
  # };
}
