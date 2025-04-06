{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.hm.shell) mkBashIntegrationOption mkZshIntegrationOption;
  cfg = config.my.nix-index;

  nix-index-database = import inputs.nix-index-database.outPath { inherit pkgs; };

  shellInit = ''
    # nix-index
    source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
  '';

  # Wrap nix-locate to use full database
  nix-index-full = pkgs.runCommand "nix-index-full" { buildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p $out/share/misc
    ln -s ${nix-index-database.nix-index-database} $out/share/misc/files
    makeWrapper ${pkgs.nix-index}/bin/nix-locate $out/bin/nix-locate \
      --set NIX_INDEX_DATABASE $out/share/misc
  '';
in
{
  options.my.nix-index = {
    enable = mkEnableOption "nix-index";
    enableBashIntegration = mkBashIntegrationOption { inherit config; };
    enableZshIntegration = mkZshIntegrationOption { inherit config; };
  };

  config = mkIf cfg.enable {
    # Use small database for command-not-found
    home.file."${config.xdg.cacheHome}/nix-index/files".source =
      nix-index-database.nix-index-small-database;

    programs.bash.initExtra = mkIf cfg.enableBashIntegration shellInit;
    programs.zsh.initExtra = mkIf cfg.enableZshIntegration shellInit;

    home.packages = [ nix-index-full ];
  };
}
