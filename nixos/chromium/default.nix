{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.chromium;
in

{
  options.programs.chromium = {
    enhance = lib.mkEnableOption "and enhance Chromium";
    package = lib.mkPackageOption pkgs "chromium" { };
  };

  config = lib.mkIf cfg.enhance {
    environment.systemPackages = [ cfg.package ];

    programs.chromium = {
      enable = true;
      extraOpts = {
        BookmarkBarEnabled = false;
        BrowserSignin = 0;
        DefaultBrowserSettingEnabled = false;
        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderKeyword = "g";
        DefaultSearchProviderName = "Google";
        DefaultSearchProviderSearchURL = "https://www.google.com/search?gl=us&gws_rd=cr&pws=0&safe=off&q={searchTerms}";
        PasswordManagerEnabled = false;
        SafeBrowsingProtectionLevel = 0; # 0 = Safe Browsing is never active
        SearchSuggestEnabled = false;
        SpellcheckEnabled = true;
        SpellcheckLanguage = [
          "en-US"
        ];
        RestoreOnStartup = 1; # 1 = Restore the last session
      };
    };
  };
}
