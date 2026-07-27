{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  cfg = config.programs.optnix;
  tomlFormat = pkgs.formats.toml { };
  # https://github.com/nix-community/nixos-cli/blob/main/nix/module.nix
  optionList = builtins.filter (v: v.visible && !v.internal) (lib.optionAttrSetToDocList options);
  optionJson = pkgs.writeText "optnix-options-cache.json" (
    builtins.unsafeDiscardStringContext (builtins.toJSON optionList)
  );
in

{
  options.programs.optnix = {
    enable = lib.mkEnableOption "programs.optnix";

    package = lib.mkPackageOption pkgs "optnix" { };

    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
    };

    settings = lib.mkOption {
      type = tomlFormat.type;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.finalPackage
    ];

    programs.optnix.finalPackage = pkgs.wrapper {
      package = cfg.package;
      flags = [
        "--config"
        (tomlFormat.generate "optnix-config.toml" cfg.settings)
      ];
    };

    programs.optnix.settings = lib.mkMerge [
      (lib.importTOML ./config.toml)
      {
        scopes.default.options-list-file = optionJson;
      }
    ];
  };
}
