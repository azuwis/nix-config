{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption;
  cfg = config.my.lazyvim.nix;
in
{
  options.my.lazyvim.nix = {
    enable = mkEnableOption "LazyVim nix support";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim.extraPackages = with pkgs; [
      nixd
      nixfmt-rfc-style
    ];

    my.neovim.treesitterParsers = [ "nix" ];

    xdg.configFile."nvim/lua/plugins/nix.lua".source = ./spec.lua;
  };
}
