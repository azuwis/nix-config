{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
  home.activation.skhd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.skhd}/bin/skhd --reload
  '';
}

else

{
  services.skhd = {
    enable = true;
    skhdConfig = ''
      lalt - 1 : yabai -m space --focus 1
      lalt - 2 : yabai -m space --focus 2
      lalt - 3 : yabai -m space --focus 3
      lalt - 4 : yabai -m space --focus 4
      lalt - 5 : yabai -m space --focus 5
      lalt - 6 : yabai -m space --focus 6
      lalt - 7 : yabai -m space --focus 7
      lalt - 8 : yabai -m space --focus 8
      lalt - 9 : yabai -m space --focus 9
      lalt - 0 : yabai -m space --focus 10
      lshift + lalt - 1 : yabai -m window --space 1
      lshift + lalt - 2 : yabai -m window --space 2
      lshift + lalt - 3 : yabai -m window --space 3
      lshift + lalt - 4 : yabai -m window --space 4
      lshift + lalt - 5 : yabai -m window --space 5
      lshift + lalt - 6 : yabai -m window --space 6
      lshift + lalt - 7 : yabai -m window --space 7
      lshift + lalt - 8 : yabai -m window --space 8
      lshift + lalt - 9 : yabai -m window --space 9
      lshift + lalt - 0 : yabai -m window --space 10
      lalt - l : yabai -m window --focus east || yabai -m window --focus stack.next
      lalt - j : yabai -m window --focus south
      lalt - h : yabai -m window --focus west || yabai -m window --focus stack.prev
      lalt - k : yabai -m window --focus north
      lshift + lalt - l : yabai -m window --swap east
      lshift + lalt - j : yabai -m window --swap south
      lshift + lalt - h : yabai -m window --swap west
      lshift + lalt - k : yabai -m window --swap north
      lshift + lalt - 0x29 : yabai -m window --toggle split
      lalt - c : yabai -m window --toggle float && yabai -m window --grid 6:6:1:1:4:4
      lalt - f : yabai -m window --toggle zoom-fullscreen; yabai -m window --grid 1:1:0:0:1:1
      lalt - m : yabai -m window --minimize
      lalt - t : yabai -m window --toggle float
      lalt - tab : yabai -m space --focus recent
      lalt - w : yabai -m space --layout stack
      lalt - e : yabai -m space --layout bsp
      lalt - s : yabai -m space --layout float
      lalt - return : ${pkgs.kitty}/Applications/kitty.app/Contents/MacOS/kitty --single-instance --directory ~
    '';
  };

  # launchd.user.agents.skhd.serviceConfig = {
  #   StandardErrorPath = "/tmp/skhd.log";
  #   StandardOutPath = "/tmp/skhd.log";
  # };
}
