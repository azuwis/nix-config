{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.retroarch;
in
{
  options.programs.retroarch = {
    enable = lib.mkEnableOption "retroarch";
    cores = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "genesis-plus-gx"
        "nestopia"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.retroarch.withCores (cores: lib.attrVals cfg.cores cores))
    ];
  };
}
