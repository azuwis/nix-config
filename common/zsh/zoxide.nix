{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.wrappers.zsh;
in
{
  options.wrappers.zsh.zoxide = {
    enable = mkEnableOption "wrappers.zsh.zoxide";
  };

  config = mkIf (cfg.enable && cfg.zoxide.enable) {
    environment.systemPackages = with pkgs; [
      zoxide
    ];

    wrappers.zsh = {
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
