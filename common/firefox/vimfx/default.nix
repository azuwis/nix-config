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

      # https://github.com/girst/LegacyFox-mirror-of-git.gir.st/blob/master/defaults/pref/config-prefs.js
      # According to the above file, the following command is needed, but VimFx works without it in real test:
      #
      # echo 'pref("general.config.sandbox_enabled", false);' >> "$prefsDir/autoconfig.js"
      extraBuildCommand = ''
        ln -s ${pkgs.legacyfox}/lib/firefox/legacy $libDir/
        ln -s ${pkgs.legacyfox}/lib/firefox/legacy.manifest $libDir/
        ln -s "${pkgs.vimfx}/${pkgs.vimfx.extid}.xpi" "$libDir/distribution/extensions/"
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
