{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    generators
    literalExpression
    mkIf
    mkOption
    types
    ;
  inherit (builtins) typeOf stringLength;

  cfg = config.wrappers.mpv;

  mpvOption = with types; either str (either int (either bool float));
  mpvOptionDup = with types; either mpvOption (listOf mpvOption);
  mpvOptions = with types; attrsOf mpvOptionDup;
  mpvProfiles = with types; attrsOf mpvOptions;
  mpvBindings = with types; attrsOf str;
  mpvDefaultProfiles = with types; listOf str;

  renderOption =
    option:
    rec {
      int = toString option;
      float = int;
      bool = if option then "yes" else "no";
      string = option;
    }
    .${typeOf option};

  renderOptionValue =
    value:
    let
      rendered = renderOption value;
      length = toString (stringLength rendered);
    in
    "%${length}%${rendered}";

  renderOptions = generators.toKeyValue {
    mkKeyValue = generators.mkKeyValueDefault { mkValueString = renderOptionValue; } "=";
    listsAsDuplicateKeys = true;
  };

  renderScriptOptions = generators.toKeyValue {
    mkKeyValue = generators.mkKeyValueDefault { mkValueString = renderOption; } "=";
    listsAsDuplicateKeys = true;
  };

  renderProfiles = generators.toINI {
    mkKeyValue = generators.mkKeyValueDefault { mkValueString = renderOptionValue; } "=";
    listsAsDuplicateKeys = true;
  };

  renderBindings =
    bindings: lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name} ${value}") bindings);

  renderDefaultProfiles = profiles: renderOptions { profile = lib.concatStringsSep "," profiles; };

  mpvHome = pkgs.linkFarm "mpv-home" (
    {
      "mpv.conf" = pkgs.writeText "mpv.conf" (
        lib.optionalString (cfg.defaultProfiles != [ ]) (renderDefaultProfiles cfg.defaultProfiles)
        + lib.optionalString (cfg.config != { }) (renderOptions cfg.config)
        + lib.optionalString (cfg.profiles != { }) (renderProfiles cfg.profiles)
        + lib.optionalString (cfg.includes != [ ]) (
          lib.concatMapStringsSep "\n" (x: "include=${x}") cfg.includes
        )
      );
      "input.conf" = pkgs.writeText "mpv-input.conf" (
        lib.optionalString (cfg.bindings != { }) (renderBindings cfg.bindings)
        + lib.optionalString (cfg.extraInput != "") cfg.extraInput
      );
    }
    // (lib.mapAttrs' (
      name: value:
      lib.nameValuePair "script-opts/${name}.conf" (
        pkgs.writeText "mpv-script-opts-${name}.conf" (renderScriptOptions value)
      )
    ) cfg.scriptOpts)
  );

  mpvPackage = pkgs.mpv.override {
    inherit (cfg) scripts;
    extraMakeWrapperArgs = [
      "--set"
      "MPV_HOME"
      mpvHome
    ];
  };

in
{
  options = {
    wrappers.mpv = {
      enable = lib.mkEnableOption "mpv";

      package = lib.mkPackageOption pkgs "mpv" {
        example = "pkgs.mpv-unwrapped.wrapper { mpv = pkgs.mpv-unwrapped.override { vapoursynthSupport = true; }; youtubeSupport = true; }";
      };

      finalPackage = mkOption {
        type = types.package;
        readOnly = true;
        visible = false;
        description = ''
          Resulting mpv package.
        '';
      };

      scripts = mkOption {
        type = with types; listOf package;
        default = [ ];
        example = literalExpression "[ pkgs.mpvScripts.mpris ]";
        description = ''
          List of scripts to use with mpv.
        '';
      };

      scriptOpts = mkOption {
        description = ''
          Script options added to
          {file}`$MPV_HOME/script-opts/`. See
          {manpage}`mpv(1)`
          for the full list of options of builtin scripts.
        '';
        type = types.attrsOf mpvOptions;
        default = { };
        example = {
          osc = {
            scalewindowed = 2.0;
            vidscale = false;
            visibility = "always";
          };
        };
      };

      config = mkOption {
        description = ''
          Configuration written to
          {file}`$MPV_HOME/mpv.conf`. See
          {manpage}`mpv(1)`
          for the full list of options.
        '';
        type = mpvOptions;
        default = { };
        example = literalExpression ''
          {
            profile = "gpu-hq";
            force-window = true;
            ytdl-format = "bestvideo+bestaudio";
            cache-default = 4000000;
          }
        '';
      };

      includes = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = literalExpression ''
          [
            "~/path/to/config.inc";
            "~/path/to/conditional.inc";
          ]
        '';
        description = "List of configuration files to include at the end of mpv.conf.";
      };

      profiles = mkOption {
        description = ''
          Sub-configuration options for specific profiles written to
          {file}`$MPV_HOME/mpv.conf`. See
          {option}`wrappers.mpv.config` for more information.
        '';
        type = mpvProfiles;
        default = { };
        example = literalExpression ''
          {
            fast = {
              vo = "vdpau";
            };
            "protocol.dvd" = {
              profile-desc = "profile for dvd:// streams";
              alang = "en";
            };
          }
        '';
      };

      defaultProfiles = mkOption {
        description = ''
          Profiles to be applied by default. Options set by them are overridden
          by options set in [](#opt-wrappers.mpv.config).
        '';
        type = mpvDefaultProfiles;
        default = [ ];
        example = [ "gpu-hq" ];
      };

      bindings = mkOption {
        description = ''
          Input configuration written to
          {file}`$MPV_HOME/input.conf`. See
          {manpage}`mpv(1)`
          for the full list of options.
        '';
        type = mpvBindings;
        default = { };
        example = literalExpression ''
          {
            WHEEL_UP = "seek 10";
            WHEEL_DOWN = "seek -10";
            "Alt+0" = "set window-scale 0.5";
          }
        '';
      };

      extraInput = mkOption {
        description = ''
          Additional lines that are appended to {file}`$MPV_HOME/input.conf`.
           See {manpage}`mpv(1)` for the full list of options.
        '';
        type = with types; lines;
        default = "";
        example = ''
          esc         quit                        #! Quit
          #           script-binding uosc/video   #! Video tracks
          # additional comments
        '';
      };
    };
  };

  config = mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = (cfg.scripts == [ ]) || (cfg.package == pkgs.mpv);
            message = ''The wrappers.mpv "package" option is mutually exclusive with "scripts" option.'';
          }
        ];
      }
      {
        wrappers.mpv.finalPackage = mpvPackage;

        environment.systemPackages = [ mpvPackage ];
      }
    ]
  );
}
