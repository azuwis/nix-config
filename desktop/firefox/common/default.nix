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
  config = lib.mkIf cfg.enable {
    programs.firefox = {
      # Example how to set default env, but allow exported env var to override
      # env.GDK_BACKEND = "\${GDK_BACKEND:-x11}";
      env.MOZ_USE_XINPUT2 = "1";

      # https://mozilla.github.io/policy-templates/
      # https://github.com/mozilla-firefox/firefox/blob/release/browser/components/enterprisepolicies/Policies.sys.mjs
      policies = {
        DisableFeedbackCommands = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        DisableSystemAddonUpdate = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = "never";
        DontCheckDefaultBrowser = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = false;
          Cryptomining = true;
          Fingerprinting = true;
          EmailTracking = true;
          # SuspectedFingerprinting = true;
        };
        # Firefox will still try to update extensions installed by `programs.firefox.extensions`, to disable:
        # ExtensionUpdate = false;
        FirefoxHome = {
          Highlights = false;
          TopSites = false;
          SponsoredTopSites = false;
          Stories = false;
          SponsoredStories = false;
        };
        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = false;
        };
        Homepage = {
          URL = "about:blank";
          StartPage = "previous-session";
          Locked = false;
        };
        NewTabPage = false;
        NoDefaultBookmarks = true;
        Permissions = {
          Autoplay = {
            Default = "allow-audio-video";
            Locked = false;
          };
          Location = {
            Block = [
              "https://baidu.com"
              "https://bing.com"
              "https://google.com"
            ];
            Locked = false;
          };
        };
        PromptForDownloadLocation = true;
        SearchEngines = {
          Add = [
            {
              Name = "G";
              URLTemplate = "https://www.google.com/search?gl=us&gws_rd=cr&pws=0&safe=off&q={searchTerms}";
              Alias = "g";
              IconURL = "https://www.google.com/favicon.ico";
            }
          ];
          Default = "G";
          Remove = [ "Google" ];
          PreventInstalls = true;
        };
        SearchSuggestEnabled = false;
        SkipTermsOfUse = true;
        TranslateEnabled = false;
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
          FeatureRecommendations = false;
          MoreFromMozilla = false;
          FirefoxLabs = false;
          Locked = false;
        };
      };

      # When preferences are unset:
      # - default: Back to Firefox default if not modified by user
      # - locked: Unable to modify, back to Firefox default
      # - user: Keep modified
      # When preferences are modified by user:
      # - default: Keep modified
      # - locked: Unable to modify
      # - user: Reset to value when Firefox restart
      preferencesStatus = "user";

      # NOTE: `programs.firefox.preferences` are are whitelisted by prefixes,
      # see https://mozilla.github.io/policy-templates/#preferences
      # preferences = { };

      # `programs.firefox.settings` are converted to autoConfig, which,
      # unlike `programs.firefox.preferences`, support all prefs
      # https://kb.mozillazine.org
      settings = {
        "browser.autofocus" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.download.manager.showAlertOnComplete" = true;
        "browser.download.manager.showWhenStarting" = false;
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false; # not covered by FirefoxHome policy
        "browser.newtabpage.activity-stream.showWeather" = false; # not covered by FirefoxHome policy
        "browser.safebrowsing.enabled" = false;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.search.region" = "US";
        "browser.search.update" = false;
        "browser.sessionstore.interval" = 300000; # 300 seconds
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.tabs.tabClipWidth" = 50;
        "browser.urlbar.trimURLs" = false;
        # compact mode
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1;
        # theme
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "layout.css.prefers-color-scheme.content-override" = 2; # websites color scheme follow theme
        # lang
        "intl.accept_languages" = "en-us,en,zh-cn,zh";
        # network
        "network.IDN_show_punycode" = true;
        "network.proxy.socks_remote_dns" = true;
        # privacy
        "privacy.donottrackheader.enabled" = true;
        "privacy.userContext.enabled" = true; # enable Container Tab
        "privacy.userContext.ui.enabled" = true;
        # reader
        "reader.color_scheme" = "sepia";
        "reader.font_type" = "serif";
        # scroll
        "apz.gtk.kinetic_scroll.enabled" = false;
        "general.autoScroll" = true;
        "general.smoothScroll" = true;
        "general.smoothScroll.mouseWheel.durationMinMS" = 100;
        "mousewheel.default.delta_multiplier_y" = 90;
        # sidebar
        "sidebar.main.tools" = "history,bookmarks";
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "always-show";
        # telemetry
        "app.normandy.enabled" = false;
        "extensions.getAddons.cache.enabled" = false;
        # geo/webrtc
        "beacon.enabled" = false;
        "browser.send_pings" = false;
        "geo.enabled" = false;
        "media.gmp-gmpopenh264.enabled" = false;
        "media.gmp-manager.url.override" = "data:text/plain,";
        "media.peerconnection.enabled" = false;
        # others
        "devtools.chrome.enabled" = true; # enable browser console command line
        "full-screen-api.warning.timeout" = 1;
        "security.dialog_enable_delay" = 0;
        "ui.caretBlinkTime" = 0; # disable cursor blinking
        "view_source.wrap_long_lines" = true;
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        "font.name.monospace.x-western" = "Menlo";
      };

      style = builtins.readFile ./style.css;
    };
  };
}
