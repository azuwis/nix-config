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
    ;
  cfg = config.programs.jujutsu;
  tomlFormat = pkgs.formats.toml { };
  scripts = ./scripts;
in
{
  options.programs.jujutsu = {
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

    programs.jujutsu.finalPackage = pkgs.wrapper {
      package = pkgs.jujutsu;
      env = {
        JJ_CONFIG = tomlFormat.generate "jujutsu-config.toml" cfg.settings;
      };
    };

    programs.jujutsu.settings = mkMerge [
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
