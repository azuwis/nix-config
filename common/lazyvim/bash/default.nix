{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.bash;
in
{
  options.my.lazyvim.bash = {
    enable = mkEnableOption "LazyVim bash support";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim.extraPackages = with pkgs; [
      nodePackages.bash-language-server
      shellcheck
      shfmt
    ];

    xdg.configFile."nvim/lua/plugins/bash.lua".source = ./spec.lua;
  };
}
