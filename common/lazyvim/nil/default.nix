{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.nil;
in
{
  options.programs.lazyvim.nil = {
    enable = mkEnableOption "LazyVim nil support";
  };

  config = lib.mkIf cfg.enable {
    programs.lazyvim = {
      extraPackages = with pkgs; [
        nil
        nixfmt
      ];
      config.nix = ./spec.lua;
      treesitterParsers = [ "nix" ];
    };
  };
}
