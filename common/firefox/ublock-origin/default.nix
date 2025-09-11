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
    programs.firefox.ublock-origin.enable = lib.mkEnableOption "uBlock origin" // {
      default = true;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.ublock-origin.enable) {
    programs.firefox = {
      extensions = [ pkgs.ublock-origin ];

      # https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin%3A-configuration
      # https://github.com/gorhill/uBlock/blob/master/src/js/storage.js
      # uBlock0 -> Settings -> Back up to file
      policies."3rdparty".Extensions."uBlock0@raymondhill.net" = {
        toOverwrite = {
          filterLists = [
            "user-filters"
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            "easylist"
            "easyprivacy"
            "urlhaus-1"
            "plowe-0"
            "fanboy-cookiemonster"
            "ublock-cookies-easylist"
            "fanboy-social"
            "easylist-chat"
            "easylist-newsletters"
            "easylist-notifications"
            "easylist-annoyances"
            "CHN-0"
          ];
        };
      };

      # Enable on private browsing
      # policies.ExtensionSettings."uBlock0@raymondhill.net".private_browsing = true;
    };
  };
}
