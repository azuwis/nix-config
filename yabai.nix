{ config, pkgs, ... }:

{
  nixpkgs.overlays = [( self: super: {
    yabai = super.yabai.overrideAttrs (o: rec {
      version = "3.3.10";
      src = builtins.fetchTarball {
        url = "https://github.com/azuwis/yabai/releases/download/v${version}/yabai-v${version}.tar.gz";
        sha256 = "0gbigxgs5n6ack56sb24y08qqyaygq8nwqdlmqqbrwdq02yps3dv";
      };

      installPhase = ''
        mkdir -p $out/bin
        mkdir -p $out/share/man/man1/
        cp ./archive/bin/yabai $out/bin/yabai
        cp ./archive/doc/yabai.1 $out/share/man/man1/yabai.1
      '';
    });
  })];

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
      window_gap = 1;
      window_shadow = "float";
    };
    extraConfig = ''
      sudo ${pkgs.yabai}/bin/yabai --load-sa
      yabai -m signal --add event=dock_did_restart action="sudo ${pkgs.yabai}/bin/yabai --load-sa"
      yabai -m rule --add app="System Preferences" manage=off
    '';
  };

  # launchd.user.agents.yabai.serviceConfig = {
  #   StandardErrorPath = "/tmp/yabai.log";
  #   StandardOutPath = "/tmp/yabai.log";
  # };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      alt - 1 : yabai -m space --focus 1
      alt - 2 : yabai -m space --focus 2
      alt - 3 : yabai -m space --focus 3
      alt - 4 : yabai -m space --focus 4
      alt - 5 : yabai -m space --focus 5
      alt - 6 : yabai -m space --focus 6
      alt - 7 : yabai -m space --focus 7
      alt - 8 : yabai -m space --focus 8
      alt - 9 : yabai -m space --focus 9
      alt - 0 : yabai -m space --focus 10
      alt - 0x32 : yabai -m space --focus recent
      alt - l : yabai -m window --focus east || yabai -m window --focus stack.next
      alt - j : yabai -m window --focus south
      alt - h : yabai -m window --focus west || yabai -m window --focus stack.prev
      alt - k : yabai -m window --focus north
      alt - c : yabai -m window --toggle float && yabai -m window --grid 6:6:1:1:4:4
      alt - f : yabai -m window --toggle zoom-fullscreen
      alt - w : yabai -m space --layout stack
      alt - e : yabai -m space --layout bsp
      alt - s : yabai -m space --layout float
      alt - return : open -na ~/Applications/Alacritty.app
    '';
  };

  home-manager.users."${config.my.user}".home.activation.skhd = ''
    ${pkgs.skhd}/bin/skhd --reload
  '';

  # launchd.user.agents.skhd.serviceConfig = {
  #   StandardErrorPath = "/tmp/skhd.log";
  #   StandardOutPath = "/tmp/skhd.log";
  # };
}
