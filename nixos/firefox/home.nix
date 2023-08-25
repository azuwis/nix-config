{ osConfig, config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  cfg = config.my.firefox;

in
{
  config = mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/issues/238025
    my.firefox.env = [ "TZ=${osConfig.time.timeZone}" ];

    programs.firefox.profiles.default.settings = {
      # https://wiki.archlinux.org/title/firefox#Hardware_video_acceleration
      "media.ffmpeg.vaapi.enabled" = true;
      "media.ffvpx.enabled" = false;
      # disable av1, vaapi on old hardware does not support av1
      "media.av1.enabled" = false;
    };
  };
}
