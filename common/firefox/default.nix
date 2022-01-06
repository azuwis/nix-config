{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
  programs.firefox = {
    package = lib.mkIf pkgs.stdenv.isDarwin (pkgs.runCommand "firefox-0.0.0" { } "mkdir $out");
    enable = true;
    profiles =
      let
        userChrome = builtins.readFile ./userChrome.css;
        settings = {
          "extensions.update.enabled" = true;
          "ui.caretBlinkTime" = 0;
          "browser.tabs.closeWindowWithLastTab" = false;
          "browser.tabs.tabClipWidth" = 50;
          "browser.ctrlTab.previews" = true;
          "network.proxy.socks_remote_dns" = true;
          "network.http.connection-timeout" = 30;
          "browser.aboutConfig.showWarning" = false;
          "browser.startup.page" = 3;
          "browser.startup.homepage" = "about:blank";
          "browser.download.useDownloadDir" = false;
          "browser.download.manager.showWhenStarting" = false;
          "browser.download.manager.showAlertOnComplete" = true;
          "intl.accept_languages" = "en-us,en,zh-cn,zh";
          "view_source.wrap_long_lines" = true;
          "browser.sessionstore.restore_on_demand" = true;
          "browser.sessionstore.interval" = 300000;
          "security.dialog_enable_delay" = 0;
          "browser.fullscreen.animate" = false;
          "browser.tabs.animate" = false;
          "toolkit.scrollbox.smoothScroll" = false;
          "toolkit.scrollbox.verticalScrollDistance" = 5;
          "privacy.donottrackheader.enabled" = true;
          "network.http.referer.userControlPolicy" = 2;
          "browser.newtabpage.enabled" = false;
          "browser.newtabpage.enhanced" = false;
          "reader.color_scheme" = "sepia";
          "reader.font_type" = "serif";
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "xpinstall.signatures.required" = false;
          "browser.urlbar.suggest.searches" = true;
          "browser.urlbar.trimURLs" = false;
          "extensions.pocket.enabled" = false;
          "browser.safebrowsing.enabled" = false;
          "browser.safebrowsing.malware.enabled" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.server" = "";
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.prompted" = 2;
          "toolkit.telemetry.rejected" = true ;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "media.peerconnection.enabled" = false;
          "beacon.enabled" = false;
          "geo.enabled" = false;
          "browser.send_pings" = false;
          "browser.fixup.alternate.enabled" = false;
          "extensions.getAddons.cache.enabled" = false;
          "media.gmp-gmpopenh264.enabled" = false;
          "media.gmp-manager.url.override" = "data:text/plain,";
          "browser.aboutHomeSnippets.updateUrl" = "";
          "browser.search.update" = false;
          "devtools.chrome.enabled" = true;
          "network.IDN_show_punycode" = true;
          "full-screen-api.warning.timeout" = -1;
          "browser.urlbar.oneOffSearches" = false;
          "privacy.userContext.enabled" = true;
          "privacy.userContext.ui.enabled" = true;
          "extensions.shield-recipe-client.enabled" = false;
          "app.shield.optoutstudies.enabled" = false;
          # "layers.omtp.enabled" = true;
          "browser.autofocus" = false;
          # "layers.acceleration.force-enabled" = true;
          # "gfx.webrender.all" = true;
          # "media.ffmpeg.vaapi.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "extensions.VimFx.config_file_directory" = "~/.vimfx";
        };
      in
      {
        default = {
          inherit settings;
          inherit userChrome;
        };
      };
  };
}

else

{
  homebrew.casks = lib.mkIf pkgs.stdenv.isDarwin [ "firefox" ];
}
