{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  imports = [
    (mkAliasOptionModule
      [
        "home-manager"
        "users"
        config.my.user
      ]
      [
        "home-manager"
        "config"
      ]
    )
  ];

  options = {
    fonts.fonts = mkOption { type = types.listOf types.str; };
    nix.settings = mkOption { type = types.submodule { freeformType = semanticConfType; }; };
    programs.zsh.enable = mkOption { type = types.bool; };
  };

  config = mkIf config.programs.zsh.enable { user.shell = "${pkgs.zsh}/bin/zsh"; };
}
