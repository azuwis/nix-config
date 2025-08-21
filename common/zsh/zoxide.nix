{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.programs.zsh;
in
{
  options.programs.zsh.zoxide = {
    enable = mkEnableOption "programs.zsh.zoxide";
  };

  config = mkIf (cfg.enable && cfg.zoxide.enable) {
    environment.systemPackages = with pkgs; [
      zoxide
    ];

    programs.zsh = {
      shellAliases = {
        c = "z";
      };
      interactiveShellInit = ''
        # zoxide
        eval "$(zoxide init zsh)"
      '';
    };
  };
}
