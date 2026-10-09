{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.rift;

  # Running the agent from an app bundle makes macOS record the Accessibility
  # grant under the bundle identifier, which tccutil reset accepts, keeping a
  # single resettable entry across rebuilds.
  riftApp =
    pkgs.runCommandLocal "rift-app"
      {
        nativeBuildInputs = [
          pkgs.makeBinaryWrapper
          pkgs.writeDarwinBundle
        ];
      }
      ''
        mkdir -p "$out/Applications/${cfg.name}.app/Contents/MacOS"
        write-darwin-bundle "$out" "${cfg.name}" "${cfg.name}"
        rm "$out/Applications/${cfg.name}.app/Contents/MacOS/${cfg.name}"
        makeBinaryWrapper "${lib.getExe cfg.package}" "$out/Applications/${cfg.name}.app/Contents/MacOS/${cfg.name}"
      '';
in

{
  options.services.rift = {
    enhance = lib.mkEnableOption "and enhance rift window manager";
    name = lib.mkOption {
      type = lib.types.str;
      default = "rift";
    };
  };

  config = lib.mkIf cfg.enhance {
    services.rift.enable = true;

    launchd.user.agents.rift = {
      environment = {
        NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      };
      serviceConfig = {
        ProgramArguments = lib.mkForce [
          "${riftApp}/Applications/${cfg.name}.app/Contents/MacOS/${cfg.name}"
          "--config"
          "${./config.toml}"
          "--restore"
        ];
        WorkingDirectory = config.users.users.${config.my.user}.home;
      };
    };

    # Save the layout during activation, then reset the Accessibility grant of
    # the replaced build so its entry does not linger.
    system.activationScripts.preActivation.text = ''
      echo "saving rift layout..." >&2
      launchctl asuser "$(id -u -- ${config.system.primaryUser})" \
        sudo -H --user=${config.system.primaryUser} -- \
        ${config.services.rift.package}/bin/rift-cli execute save-layout --master || true

      if [ -e /run/current-system/sw/bin/rift ]; then
        if [ "$(readlink -f /run/current-system/sw/bin/rift)" != "${lib.getExe cfg.package}" ]; then
          echo "resetting rift accessibility permission..." >&2
          launchctl asuser "$(id -u -- ${config.system.primaryUser})" \
            sudo -H --user=${config.system.primaryUser} -- \
            /usr/bin/tccutil reset Accessibility org.nixos.${cfg.name} || true
        fi
      fi
    '';
  };
}
