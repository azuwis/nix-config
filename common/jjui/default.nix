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
  cfg = config.programs.jjui;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.programs.jjui = {
    enable = mkEnableOption "jjui";

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
    environment.systemPackages = [
      cfg.finalPackage
    ];

    programs.jjui.finalPackage = pkgs.wrapper {
      package = pkgs.jjui;
      env = {
        JJUI_CONFIG_DIR = pkgs.runCommandLocal "jjui-config-dir" { } ''
          mkdir -p "$out"
          ln -s ${tomlFormat.generate "config.toml" cfg.settings} "$out/config.toml"
        '';
      };
    };

    programs.jjui.settings = mkMerge [
      (importTOML ./config.toml)
    ];
  };
}
