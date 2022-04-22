{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
  programs.firefox.profiles.default.settings = {
    # https://wiki.archlinux.org/title/firefox#Hardware_video_acceleration
    "media.ffmpeg.vaapi.enabled" = true;
    "media.ffvpx.enabled" = false;
    # disable av1, vaapi on old hardware does not support av1
    "media.av1.enabled" = false;
  };
}

else

{
  # https://bugzilla.mozilla.org/show_bug.cgi?id=1751363
  environment.variables.MOZ_DISABLE_RDD_SANDBOX = "1";
}