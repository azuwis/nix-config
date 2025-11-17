{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.bash;
in
{
  options.programs.lazyvim.bash = {
    enable = mkEnableOption "LazyVim bash support";
  };

  config = lib.mkIf cfg.enable {
    programs.lazyvim = {
      extraPackages = with pkgs; [
        shellcheck
        shfmt
      ];
      config.bash = ./spec.lua;
      treesitterParsers = [ "bash" ];
    };
  };
}
