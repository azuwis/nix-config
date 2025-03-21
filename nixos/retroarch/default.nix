{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    attrVals
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.my.retroarch;
in
{
  options.my.retroarch = {
    enable = mkEnableOption "retroarch";
    cores = mkOption {
      type = types.listOf types.str;
      default = [
        "genesis-plus-gx"
        "nestopia"
      ];
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.retroarch.withCores (cores: attrVals cfg.cores cores))
    ];
  };
}
