{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nix;
in

{
  options.nix = {
    enable = lib.mkEnableOption "nix" // {
      default = true;
    };
    singleUser = lib.mkEnableOption "nix single user";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.file.".config/nix/registry.json".source = config.environment.etc."nix/registry.json".source;
      }

      (lib.mkIf cfg.singleUser {
        environment.pathsToLink = [ "/etc/profile.d" ];
        environment.systemPackages = [ pkgs.nix ];
      })
    ]
  );
}
