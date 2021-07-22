{ config, pkgs, ... }:

{
  environment.etc."sudoers.d/custom".text = ''
    azuwis ALL = (root) NOPASSWD: /opt/homebrew/opt/yabai/bin/yabai --load-sa
  '';
  homebrew = {
    taps = [
      "xorpse/formulae"
    ];
    extraConfig = ''
      brew "xorpse/formulae/yabai", args:["HEAD"]
    '';
  };
}
