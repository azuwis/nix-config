{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.programs.emacs;
in
{
  options.programs.emacs = {
    enable = mkEnableOption "emacs";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.emacs ];

    fonts.packages = [ pkgs.emacs-all-the-icons-fonts ];

    home.file.".doom.d".source = ./doom.d;
  };
}
