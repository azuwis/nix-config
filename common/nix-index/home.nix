{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.nix-index;

  nix-index-database = import inputs.nix-index-database.outPath { inherit pkgs; };
in
{
  options.my.nix-index = {
    enable = mkEnableOption "nix-index";
  };

  config = mkIf cfg.enable {
    programs.nix-index.enable = true;

    home.file."${config.xdg.cacheHome}/nix-index/files".source = nix-index-database.nix-index-database;
  };
}
