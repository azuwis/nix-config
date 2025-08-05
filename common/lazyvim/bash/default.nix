{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.wrappers.lazyvim.bash;
in
{
  options.wrappers.lazyvim.bash = {
    enable = mkEnableOption "LazyVim bash support";
  };

  config = lib.mkIf cfg.enable {
    wrappers.lazyvim = {
      extraPackages = with pkgs; [
        bash-language-server
        shellcheck
        shfmt
      ];
      config.bash = ./spec.lua;
      treesitterParsers = [ "bash" ];
    };
  };
}
