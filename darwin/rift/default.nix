{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.rift;
in

{
  options.services.rift = {
    enhance = lib.mkEnableOption "and enhance rift window manager";
  };

  config = lib.mkIf cfg.enhance {
    services.rift.enable = true;

    launchd.user.agents.rift = {
      environment = {
        NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      };
      serviceConfig = {
        ProgramArguments = lib.mkAfter [
          "--config"
          "${./config.toml}"
          "--restore"
        ];
        WorkingDirectory = config.users.users.${config.my.user}.home;
      };
    };

    # Save the layout during activation.
    system.activationScripts.preActivation.text = ''
      echo "saving rift layout..." >&2
      launchctl asuser "$(id -u -- ${config.system.primaryUser})" \
        sudo -H --user=${config.system.primaryUser} -- \
        ${config.services.rift.package}/bin/rift-cli execute save-layout --master || true
    '';
  };
}
