{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.sillytavern;
in

{
  options.services.sillytavern = {
    enhance = lib.mkEnableOption "and enhance sillytavern";
  };

  config = lib.mkIf cfg.enhance {
    services.sillytavern.enable = true;

    systemd.services.sillytavern.environment.NODE_ENV = "production";

    # SillyTavern try to write config.yaml if config is partial
    # https://github.com/NixOS/nixpkgs/issues/455581
    systemd.services.sillytavern.preStart = ''
      cp --no-preserve=all --remove-destination ${./config.yaml} /var/lib/SillyTavern/config.yaml
    '';
    systemd.tmpfiles.settings.sillytavern."/var/lib/SillyTavern/config.yaml" = lib.mkForce { };
  };
}
