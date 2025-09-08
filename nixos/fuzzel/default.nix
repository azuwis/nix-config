{
  config,
  lib,
  pkgs,
  ...
}:

let

  inherit (lib)
    literalExpression
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    ;

  cfg = config.programs.fuzzel;

  iniFormat = pkgs.formats.ini { };

in
{
  options.programs.fuzzel = {
    enable = mkEnableOption "fuzzel";

    package = mkPackageOption pkgs "fuzzel" { };

    settings = mkOption {
      type = iniFormat.type;
      default = { };
      example = literalExpression ''
        {
          main = {
            terminal = "''${pkgs.foot}/bin/foot";
            layer = "overlay";
          };
          colors.background = "ffffffff";
        }
      '';
      description = ''
        Configuration for fuzzel written to
        {file}`/etc/xdg/fuzzel/fuzzel.ini`. See
        {manpage}`fuzzel.ini(5)` for a list of available options.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    environment.etc."xdg/fuzzel/fuzzel.ini" = mkIf (cfg.settings != { }) {
      source = iniFormat.generate "fuzzel.ini" cfg.settings;
    };
  };
}
