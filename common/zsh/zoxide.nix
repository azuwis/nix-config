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
    environment.shellAliases = {
      c = "z";
    };

    environment.systemPackages = with pkgs; [
      zoxide
    ];

    programs.zsh.interactiveShellInit = ''
      # zoxide
      eval "$(zoxide init zsh)"
    '';
  };
}
