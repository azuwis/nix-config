{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.firefox;
in

{
  options = {
    programs.firefox.vimfx.enable = lib.mkEnableOption "VimFx" // {
      default = true;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.vimfx.enable) {
    programs.firefox = {
      autoConfigFiles = [
        "${pkgs.legacyfox}/lib/firefox/config.js"
      ];

      extensions = [ pkgs.vimfx ];

      # https://searchfox.org/mozilla-central/source/extensions/pref/autoconfig/src/nsReadConfig.cpp#140
      # nsReadConfig.cpp defaults sandboxEnabled by MOZ_UPDATE_CHANNEL:
      #   true  for "release" | "beta"       (e.g. pkgs.firefox-bin)
      #   false for "default" | "nightly"    (e.g. pkgs.firefox)
      # Explictly set to false for vimfx
      # https://github.com/girst/LegacyFox-mirror-of-git.gir.st/blob/master/defaults/pref/config-prefs.js
      extraBuildCommand = ''
        echo 'pref("general.config.sandbox_enabled", false);' >> "$prefsDir/autoconfig.js"
        ln -s ${pkgs.legacyfox}/lib/firefox/legacy $libDir/
        ln -s ${pkgs.legacyfox}/lib/firefox/legacy.manifest $libDir/
      '';

      settings =
        let
          dir = ./config;
        in
        {
          "extensions.VimFx.config_file_directory" = "${dir}";
          # https://github.com/akhodakivskiy/VimFx/blob/master/documentation/known-bugs.md
          "fission.bfcacheInParent" = false;
          # "fission.autostart" = false;
          # https://github.com/akhodakivskiy/VimFx/blob/master/documentation/config-file.md
          "security.sandbox.content.mac.testing_read_path1" = "${dir}/frame.js";
          "security.sandbox.content.read_path_whitelist" = "${dir}/frame.js";
        };

      style = builtins.readFile ./style.css;
    };
  };
}
