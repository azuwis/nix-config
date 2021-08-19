{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [( self: super: {
    yabai = super.yabai.overrideAttrs (o: rec {
      version = "3.3.10-1";
      src = builtins.fetchTarball {
        url = "https://github.com/azuwis/yabai/releases/download/v3.3.10/yabai-v${version}.tar.gz";
        sha256 = "1za1b3hdns9hhhwpq3fvya2528rc17cyz9sl0jq4q6y1i35jkrm6";
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
      sudo yabai --load-sa
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
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
      shift + alt - 1 : yabai -m window --space 1
      shift + alt - 2 : yabai -m window --space 2
      shift + alt - 3 : yabai -m window --space 3
      shift + alt - 4 : yabai -m window --space 4
      shift + alt - 5 : yabai -m window --space 5
      shift + alt - 6 : yabai -m window --space 6
      shift + alt - 7 : yabai -m window --space 7
      shift + alt - 8 : yabai -m window --space 8
      shift + alt - 9 : yabai -m window --space 9
      shift + alt - 0 : yabai -m window --space 10
      alt - l : yabai -m window --focus east || yabai -m window --focus stack.next
      alt - j : yabai -m window --focus south
      alt - h : yabai -m window --focus west || yabai -m window --focus stack.prev
      alt - k : yabai -m window --focus north
      shift + alt - l : yabai -m window --swap east
      shift + alt - j : yabai -m window --swap south
      shift + alt - h : yabai -m window --swap west
      shift + alt - k : yabai -m window --swap north
      shift + alt - 0x29 : yabai -m window --toggle split
      alt - c : yabai -m window --toggle float && yabai -m window --grid 6:6:1:1:4:4
      alt - f : yabai -m window --toggle zoom-fullscreen
      alt - m : yabai -m window --minimize
      alt - tab : yabai -m space --focus recent
      alt - w : yabai -m space --layout stack
      alt - e : yabai -m space --layout bsp
      alt - s : yabai -m space --layout float
      alt - return : open -na ~/Applications/Alacritty.app
    '';
  };

  home-manager.users."${config.my.user}" = { pkgs, lib, ... }: {
    home.activation.skhd = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.skhd}/bin/skhd --reload
    '';
  };

  # launchd.user.agents.skhd.serviceConfig = {
  #   StandardErrorPath = "/tmp/skhd.log";
  #   StandardOutPath = "/tmp/skhd.log";
  # };
}
