{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    importTOML
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optionalAttrs
    ;
  cfg = config.wrappers.jujutsu;
  tomlFormat = pkgs.formats.toml { };
  scripts = ./scripts;
in
{
  options.wrappers.jujutsu = {
    enable = mkEnableOption "jujutsu";

    finalPackage = mkOption {
      type = lib.types.package;
      readOnly = true;
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.finalPackage ];

    wrappers.jujutsu.finalPackage = pkgs.wrapper {
      package = pkgs.jujutsu;
      env =
        {
          JJ_CONFIG = tomlFormat.generate "jujutsu-config.toml" cfg.settings;
        }
        // optionalAttrs config.wrappers.git.enable {
          GIT_CONFIG_GLOBAL = config.wrappers.git.configFile;
        };
    };

    wrappers.jujutsu.settings = mkMerge [
      (importTOML ./config.toml)
      {
        aliases = {
          ni = [
            "util"
            "exec"
            "--"
            "${scripts}/ni"
          ];
          pr = [
            "util"
            "exec"
            "--"
            "${scripts}/pr"
          ];
        };
        user = {
          inherit (config.my) email name;
        };
      }
    ];
  };
}
