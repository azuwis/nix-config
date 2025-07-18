{
  config,
  lib,
  pkgs,
  wrapper,
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
  cfg = config.wrappers.jujutsu;
  tomlFormat = pkgs.formats.toml { };
  scripts = ./scripts;
in
{
  options.wrappers.jujutsu = {
    enable = mkEnableOption "jujutsu";

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (wrapper {
        basePackage = pkgs.jujutsu;
        env.JJ_CONFIG.value = tomlFormat.generate "jujutsu-config.toml" cfg.settings;
      })
    ];

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
