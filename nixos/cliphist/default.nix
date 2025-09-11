{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.programs.cliphist;
in
{
  options.programs.cliphist = {
    enable = mkEnableOption "cliphist";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cliphist
      wl-clipboard
    ];

    programs.wayland.startup.cliphist = [
      "wl-paste"
      "--watch"
      "cliphist"
      "store"
    ];

    programs.sway.extraConfig = ''
      bindsym $mod+p exec tmenu sh -c 'cliphist list | fzf --reverse --no-info | cliphist decode 2>/dev/null | wl-copy'
    '';
  };
}
