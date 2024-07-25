{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkAliasOptionModule
    mkIf
    mkOption
    semanticConfType
    types
    ;
  dummyOption = mkOption { type = types.submodule { freeformType = semanticConfType; }; };
in

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
    fonts.packages = dummyOption;
    nix.gc = dummyOption;
    nix.optimise = dummyOption;
    nix.settings = dummyOption;
    programs.zsh.enable = mkOption { type = types.bool; };
  };

  config = mkIf config.programs.zsh.enable { user.shell = "${pkgs.zsh}/bin/zsh"; };
}
