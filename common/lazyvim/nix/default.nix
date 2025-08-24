{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.programs.lazyvim.nix;
in
{
  options.programs.lazyvim.nix = {
    enable = mkEnableOption "LazyVim nix support";
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
