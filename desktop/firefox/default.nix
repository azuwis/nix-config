{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.firefox;

  jsonFormat = pkgs.formats.json { };
in

{
  imports = [
    ./bookmarklets
    ./common
    ./ublock-origin
    ./vimfx
  ];

  options.programs.firefox = {
    enhance = lib.mkEnableOption "and enhance Firefox";
    env = lib.mkOption {
      type =
        with lib.types;
        attrsOf (
          nullOr (oneOf [
            str
            path
            package
          ])
        );
      default = { };
    };

    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };

    extraBuildCommand = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };

    basePackage = lib.mkPackageOption pkgs "firefox" { };

    settings = lib.mkOption {
      type = lib.types.attrsOf jsonFormat.type;
    };

    userChrome = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };

    userContent = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };

  config = lib.mkIf cfg.enhance {
    # `programs.firefox.policies` generates `/etc/firefox/policies/policies.json`,
    # but Firefox on darwin does not read it, disable it and use `extraPolicies`
    # to handle that, see below
    environment.etc."firefox/policies/policies.json".enable = false;

    programs.firefox = {
      enable = true;
      autoConfig =
        let
          prefValue =
            pref:
            builtins.toJSON (
              if lib.isBool pref || lib.isInt pref || lib.isString pref then pref else builtins.toJSON pref
            );
        in
        # Can use `pref` `defaultPref` `lockPref`, see preferencesStatus in ./common/default.nix
        lib.concatStrings (
          lib.mapAttrsToList (name: value: ''
            pref("${name}", ${prefValue value});
          '') cfg.settings
        )
        # Firefox selects native userChrome.css/userContent.css by docshell type,
        # whereas document-global-created topics are selected by principal.
        #
        # Browser UI and system-principal content pages (such as about:config and
        # about:preferences) all emit chrome-document-global-created in the parent.
        # Use isContent to inject userChrome into browser UI and userContent into
        # content docshells.
        #
        # Non-system-principal documents, including web pages and safe remote about:
        # pages such as about:newtab, emit content-document-global-created in content
        # processes. Since autoconfig runs in the parent, install the userContent
        # observer in content processes with loadProcessScript.
        + (
          let
            userChromeCss = pkgs.writeText "userChrome.css" cfg.userChrome;
            userContentCss = pkgs.writeText "userContent.css" cfg.userContent;
            userContentJs = pkgs.writeText "userContent.js" ''
              (function() {
                const sss = Components.classes["@mozilla.org/content/style-sheet-service;1"].getService(Components.interfaces.nsIStyleSheetService);
                const userContent = sss.preloadSheet(Services.io.newURI("file://${userContentCss}"), sss.USER_SHEET);
                Services.obs.addObserver((win) => {
                  win.windowUtils.addSheet(userContent, Components.interfaces.nsIDOMWindowUtils.USER_SHEET);
                }, "content-document-global-created");
              })();
            '';
          in
          # Browser UI in the parent process
          lib.optionalString (cfg.userChrome != "") ''
            try {
              const sss = Components.classes["@mozilla.org/content/style-sheet-service;1"].getService(Components.interfaces.nsIStyleSheetService);
              let userChrome = null;
              Services.obs.addObserver((win) => {
                if (win.browsingContext && !win.browsingContext.isContent) {
                  if (!userChrome) {
                    userChrome = sss.preloadSheet(Services.io.newURI("file://${userChromeCss}"), sss.USER_SHEET);
                  }
                  win.windowUtils.addSheet(userChrome, Components.interfaces.nsIDOMWindowUtils.USER_SHEET);
                }
              }, "chrome-document-global-created");
            } catch (ex) {
              Components.utils.reportError(ex.message);
            }
          ''
          # Content documents in parent and content processes
          + lib.optionalString (cfg.userContent != "") ''
            try {
              Services.ppmm.loadProcessScript("file://${userContentJs}", true);
            } catch (ex) {
              Components.utils.reportError(ex.message);
            }
            try {
              const sss = Components.classes["@mozilla.org/content/style-sheet-service;1"].getService(Components.interfaces.nsIStyleSheetService);
              let userContent = null;
              Services.obs.addObserver((win) => {
                if (win.browsingContext && win.browsingContext.isContent) {
                  if (!userContent) {
                    userContent = sss.preloadSheet(Services.io.newURI("file://${userContentCss}"), sss.USER_SHEET);
                  }
                  win.windowUtils.addSheet(userContent, Components.interfaces.nsIDOMWindowUtils.USER_SHEET);
                }
              }, "chrome-document-global-created");
            } catch (ex) {
              Components.utils.reportError(ex.message);
            }
          ''
        );

      package =
        let
          envWrapperArgs = lib.flatten (
            lib.mapAttrsToList (name: value: [
              "--set"
              name
              value
            ]) (lib.filterAttrs (name: value: value != null) cfg.env)
          );
          extensionsBuildCommand = lib.concatMapStrings (
            entry: "ln -s \"${entry}/${entry.extid}.xpi\" \"$libDir/distribution/extensions/\"\n"
          ) cfg.extensions;
        in
        (cfg.basePackage.override (old: {
          # `programs.firefox.policies` generates `/etc/firefox/policies/policies.json`,
          # but Firefox on darwin does not read it.
          # Use `extraPolicies` to handle `programs.firefox.policies`, it will generate
          # `<firefox-dir>/distribution/policies.json`, and works on all platforms
          extraPolicies = (old.extraPolicies or { }) // cfg.policies;
        })).overrideAttrs
          (old: {
            buildCommand = old.buildCommand + cfg.extraBuildCommand + extensionsBuildCommand;
            makeWrapperArgs = old.makeWrapperArgs ++ envWrapperArgs;
          });
    };
  };
}
