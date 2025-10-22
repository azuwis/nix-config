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

    settings = lib.mkOption {
      type = lib.types.attrsOf jsonFormat.type;
    };

    style = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    # `programs.firefox.policies` generates `/etc/firefox/policies/policies.json`,
    # but Firefox on darwin does not read it, disable it and use `extraPolicies`
    # to handle that, see bellow
    environment.etc."firefox/policies/policies.json".enable = false;

    programs.firefox = {
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
        + lib.optionalString (cfg.style != "") ''
          try {
            let sss = Components.classes["@mozilla.org/content/style-sheet-service;1"].getService(Components.interfaces.nsIStyleSheetService);
            let uri = Services.io.newURI("file://${pkgs.writeText "userChrome.css" cfg.style}", sss.USER_SHEET);
            if (!sss.sheetRegistered(uri, sss.USER_SHEET)) {
              sss.loadAndRegisterSheet(uri, sss.USER_SHEET);
            }
          } catch(ex){
            Components.utils.reportError(ex.message);
          }
        '';

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
        (pkgs.firefox.override (old: {
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
