{ config, lib, pkgs, ... }:

let

  buildFirefoxXpiAddon = lib.makeOverridable ({ stdenv ? pkgs.stdenv
    , fetchurl ? pkgs.fetchurl, pname, version, addonId, url, sha256, meta, ...
    }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    });

  vimfx = buildFirefoxXpiAddon rec {
    pname = "vimfx";
    version = "0.24.6";
    addonId = "VimFx-unlisted@akhodakivskiy.github.com";
    url = "https://github.com/akhodakivskiy/VimFx/releases/download/v${version}/VimFx.xpi";
    sha256 = "sha256-1NRQAjQ2uopC75xwWskjXCCWfq+we3fctlR5ZezjM+I=";
    meta = with lib; {
      homepage = "https://github.com/akhodakivskiy/VimFx";
      description = "Vim keyboard shortcuts for Firefox";
    };
  };

  firefox = pkgs.firefox-wayland.overrideAttrs(o: {
    buildCommand = o.buildCommand + ''
      # conflict with legacyfox
      rm $out/lib/firefox/defaults/pref/autoconfig.js
      lndir -silent ${pkgs.legacyfox} $out
    '';
  });

in

{
  home.activation.vimfx = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.rsync}/bin/rsync -a ${./vimfx}/ ~/.config/vimfx/
  '';
  programs.firefox = {
    enable = true;
    package = lib.mkDefault firefox;
    extensions = [ vimfx ];
    profiles =
      let
        # userChrome = builtins.readFile (builtins.fetchurl {
        #   url = "https://raw.githubusercontent.com/andreasgrafen/cascade/a16181ec77da1872f102e51bcf2739c627b03a1b/userChrome.css";
        #   sha256 = "1h7kzr5mprv5q8a5bwp1hil25hl5qfjlncnq1ailvx7k4nlg71nz";
        # });
        userChrome = builtins.readFile ./userChrome.css;
        settings = {
          "extensions.update.enabled" = true;
          "ui.caretBlinkTime" = 0;
          "browser.compactmode.show" = true;
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
          "browser.urlbar.suggest.engines" = false;
          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
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
          "browser.autofocus" = false;
          # "layers.omtp.enabled" = true;
          # "layers.acceleration.force-enabled" = true;
          # "gfx.webrender.all" = true;
          "media.hardware-video-decoding.force-enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "media.autoplay.default" = 0;
          "extensions.VimFx.config_file_directory" = "~/.config/vimfx";
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
