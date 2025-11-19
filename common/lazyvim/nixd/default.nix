{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.nixd;
in
{
  options.programs.lazyvim.nixd = {
    enable = mkEnableOption "LazyVim nixd support";
  };

  config = lib.mkIf cfg.enable {
    programs.lazyvim = {
      extraPackages = with pkgs; [
        nixd
        nixfmt-rfc-style
      ];
      config.nix = ./spec.lua;
      treesitterParsers = [ "nix" ];
    };
  };
}
