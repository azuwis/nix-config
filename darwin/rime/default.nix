{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.rime;
in
{
  options.my.rime = {
    enable = mkEnableOption "rime";
  };

  config = mkIf cfg.enable {
    hm.my.rime.enable = true;

    homebrew.casks = mkIf config.homebrew.enable [ "squirrel" ];
  };
}
