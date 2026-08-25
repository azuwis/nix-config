{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.thunderbird;

  jsonFormat = pkgs.formats.json { };
in

{
  options.programs.thunderbird = {
    enhance = lib.mkEnableOption "and enhance Thunderbird";

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

    basePackage = lib.mkPackageOption pkgs "thunderbird" { };

    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default =
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
          # `programs.thunderbird.policies` generates `/etc/thunderbird/policies/policies.json`,
          # but Thunderbird on darwin does not read it.
          # Use `extraPolicies` to handle `programs.thunderbird.policies`, it will generate
          # `<thunderbird-dir>/distribution/policies.json`, and works on all platforms
          extraPolicies = (old.extraPolicies or { }) // cfg.policies;
        })).overrideAttrs
          (old: {
            buildCommand = old.buildCommand + cfg.extraBuildCommand + extensionsBuildCommand;
            makeWrapperArgs = old.makeWrapperArgs ++ envWrapperArgs;
          });
    };
  };

  config = lib.mkIf cfg.enhance {
    # `programs.thunderbird.policies` generates `/etc/thunderbird/policies/policies.json`,
    # but Thunderbird on darwin does not read it, disable it and use `extraPolicies`
    # to handle that, see below
    environment.etc."thunderbird/policies/policies.json".enable = false;

    programs.thunderbird = {
      enable = true;
      env.MOZ_USE_XINPUT2 = "1";
      package = cfg.finalPackage;
      policies = {
        DisableTelemetry = true;
        PromptForDownloadLocation = true;
        # https://thunderbird.github.io/policy-templates/templates/central/#preferences
        Preferences = {
          "mail.server.default.check_all_folders_for_new" = {
            Status = "user";
            Value = true;
          };
        };
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
      };
    };
  };
}
