{ config, lib, pkgs, ... }:

{
  # csrutil enable --without fs --without debug --without nvram
  # nvram boot-args=-arm64e_preview_abi
  environment.etc."sudoers.d/yabai".text = ''
    ${config.my.user} ALL = (root) NOPASSWD: ${pkgs.yabai}/bin/yabai --load-sa
  '';

  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    config = {
      auto_balance = "on";
      layout = "bsp";
      mouse_modifier = "alt";
      window_shadow = "float";
    };
    extraConfig = ''
      sudo yabai --load-sa
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
      yabai -m rule --add app="^(Digital Color Meter|System Preferences|mpv)$" manage=off
      yabai -m rule --add app="^alacritty$" title="^Passmenu$" manage=off
      yabai -m rule --add app="^Safari$" space=2
      yabai -m rule --add app="^Mail$" space=3
      yabai -m rule --add app="^网易POPO$" title="^$" manage=off space=5 grid=1:1:0:0:1:1
      yabai -m space 5 --layout float
    '';
  };

  # launchd.user.agents.yabai.serviceConfig = {
  #   StandardErrorPath = "/tmp/yabai.log";
  #   StandardOutPath = "/tmp/yabai.log";
  # };
}
