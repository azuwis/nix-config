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

    system.activationScripts.preActivation.text = ''
      echo "saving rift layout..." >&2
      launchctl asuser "$(id -u -- ${config.system.primaryUser})" \
        sudo -H --user=${config.system.primaryUser} -- \
        ${config.services.rift.package}/bin/rift-cli execute save-layout --master || true

      if [ -e /run/current-system/sw/bin/rift ]; then
        if [ "$(readlink -f /run/current-system/sw/bin/rift)" != "${lib.getExe cfg.package}" ]; then
          # Reset the Accessibility grant of the replaced build so its entry does not linger.
          echo "resetting rift accessibility permission..." >&2
          launchctl asuser "$(id -u -- ${config.system.primaryUser})" \
            sudo -H --user=${config.system.primaryUser} -- \
            /usr/bin/tccutil reset Accessibility org.nixos.${cfg.name} || true

          # The agent plist still points at the previous build. Unregister that
          # bundle, otherwise LaunchServices records pile up one per rebuild.
          plist=${config.system.primaryUserHome}/Library/LaunchAgents/org.nixos.rift.plist
          if [ -e "$plist" ]; then
            oldApp=$(/usr/bin/plutil -extract ProgramArguments.0 raw "$plist" || true)
            oldBundle=''${oldApp%/Contents/MacOS/*}
            if [ "$oldBundle" != "$oldApp" ]; then
              echo "unregistering previous rift app bundle..." >&2
              lsregister=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
              launchctl asuser "$(id -u -- ${config.system.primaryUser})" \
                sudo -H --user=${config.system.primaryUser} -- \
                "$lsregister" -u "$oldBundle" || true
            fi
          fi
        fi
      fi
    '';

    system.activationScripts.postActivation.text = ''
      echo "removing rift layout..." >&2
      launchctl asuser "$(id -u -- ${config.system.primaryUser})" \
        sudo -H --user=${config.system.primaryUser} -- \
        rm -f ${config.system.primaryUserHome}/.rift/layout.ron || true
    '';
  };
}
