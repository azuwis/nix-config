{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.wrappers.lazyvim.nix;
in
{
  options.wrappers.lazyvim.nix = {
    enable = mkEnableOption "LazyVim nix support";
  };

  config = lib.mkIf cfg.enable {
    wrappers.lazyvim = {
      extraPackages = with pkgs; [
        nixd
        nixfmt-rfc-style
      ];
      config.nix = ./spec.lua;
      treesitterParsers = [ "nix" ];
    };
  };
}
