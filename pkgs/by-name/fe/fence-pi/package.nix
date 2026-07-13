{
  lib,
  stdenv,
  buildNpmPackage,
  fence-agent,
  fetchFromGitHub,
  linkFarm,
  pi-coding-agent,
  writeScript,
  piExtensions ? {
    pi-exa-mcp =
      let
        version = "2026-07-12";
      in
      {
        inherit version;
      }
      // fetchFromGitHub {
        owner = "ben-vargas";
        repo = "pi-packages";
        tag = version;
        rootDir = "packages/pi-exa-mcp";
        hash = "sha256-Wqw+Gp7skL5S4xB9Ktq9rs6F6ulA1XAuXb9PKe2pQV0=";
      };
    pi-hashline-edit-pro = buildNpmPackage (finalAttrs: {
      pname = "pi-hashline-edit-pro";
      version = "0-unstable-2026-07-12";
      src = fetchFromGitHub {
        owner = "YuGiMob";
        repo = "pi-hashline-edit-pro";
        rev = "de305c8647fcae4c7e1277fcd511d31544309f6e";
        hash = "sha256-xdv71zz4epMFWCnfQmIht43eeDppS/xRIjK26yEXRqs=";
      };
      npmDepsHash = "sha256-7qu5WHyJFeknDFGB51dBw8ORfxmDs+qCnlou5xbuV3g=";
      npmInstallFlags = [
        "--omit=dev"
        "--omit=peer"
      ];
      dontNpmBuild = true;
      installPhase = ''
        runHook preInstall
        cp -r . $out
        runHook postInstall
      '';
    });
    pi-superpowers = {
      version = "0-unstable-2026-03-05";
    }
    // fetchFromGitHub {
      owner = "coctostan";
      repo = "pi-superpowers";
      rev = "efe1d158691bf064c24f0460fd4e46ca58de0055";
      hash = "sha256-cwGs/Hdbk3h9Yk+vEMtXSyAgy+grxEc6eZAHZZjpcDk=";
    };
    pi-monorepo-subagent = "${pi-coding-agent}/lib/node_modules/pi-monorepo/examples/extensions/subagent";
  },
}:

# Network access: configure in ~/.config/fence/fence.json, e.g.:
# {
#   "network": {
#     "allowedDomains": ["your.api.address"],
#     "deniedDomains": ["*.sentry.io"]
#   }
# }

let
  extensionsDir = linkFarm "pi-extensions" piExtensions;
in

fence-agent {
  name = "fence-pi";
  agentPackage = pi-coding-agent;
  allowWrite = [
    "."
    "~/.pi"
  ];
  agentWrapperArgs = [
    "--set"
    "PI_OFFLINE"
    "true"
    "--set"
    "PI_TELEMETRY"
    "false"
    "--add-flags"
    "${lib.concatMapAttrsStringSep " " (name: _: "--extension ${extensionsDir}/${name}") piExtensions}"
  ];
  preExecScript = ''
    mkdir -p ~/.pi
  '';
  extraPassthru = {
    extensionsUpdate = builtins.mapAttrs (
      name: plugin:
      if plugin ? src then
        plugin
      else
        stdenv.mkDerivation {
          pname = "pi-plugin-${name}";
          version = plugin.version or "0";
          src = plugin;
        }
    ) piExtensions;
    updateScript = {
      command = writeScript "update-fence-pi" ''
        #!/usr/bin/env nix-shell
        #!nix-shell -i bash -p gawk gitMinimal nix-update

        set -euo pipefail

        nix-update fence-pi.extensionsUpdate.pi-exa-mcp >&2
        nix-update fence-pi.extensionsUpdate.pi-hashline-edit-pro --version=branch >&2
        nix-update fence-pi.extensionsUpdate.pi-superpowers --version=branch >&2

        git diff HEAD | awk '
          /^ +[a-z][-a-z0-9]* =($| [^"])/   { name = $1 }
          /^-\s+version =/              { split($0, a, "\""); old = a[2] }
          /^\+\s+version =/ {
            split($0, a, "\"")
            if (old != a[2]) {
              if (msg) msg = msg ", "
              msg = msg name " " old " -> " a[2]
            }
          }
          END {
            if (!msg) print "[]"
            else printf "[{\"commitMessage\":\"fence-pi: %s\"}]\n", msg
          }'
      '';
      supportedFeatures = [ "commit" ];
    };
  };
}
