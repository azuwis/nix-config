{
  lib,
  stdenvNoCC,
  buildNpmPackage,
  fetchFromGitHub,
  linkFarm,
  pen,
  pi-coding-agent,
  writeScript,
  piExtensions ? {
    pi-exa-mcp =
      let
        version = "2026-07-16";
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
      version = "0-unstable-2026-07-23";
      src = fetchFromGitHub {
        owner = "YuGiMob";
        repo = "pi-hashline-edit-pro";
        rev = "5d97f2a0d8aaa0e06a637583845263ed2ca455f1";
        hash = "sha256-UOAalDCmw/bnRWU76eIOP+sHBc43BmDXZF5D8J0v9G4=";
      };
      npmDepsHash = "sha256-kVPTPl1uhhA6ap8fePANELTIw4Ik59BrqU/7bh9kSuw=";
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

let
  extensionsDir = linkFarm "pi-extensions" piExtensions;
in

pen {
  name = "pen-pi";
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
  extraPassthru = {
    extensionsUpdate = builtins.mapAttrs (
      name: plugin:
      if plugin ? src then
        plugin
      else
        stdenvNoCC.mkDerivation {
          pname = "pi-plugin-${name}";
          version = plugin.version or "0";
          src = plugin;
        }
    ) piExtensions;
    updateScript = {
      command = writeScript "update-pen-pi" ''
        #!/usr/bin/env nix-shell
        #!nix-shell -i bash -p gawk gitMinimal nix-update

        set -euo pipefail

        nix-update pen-pi.extensionsUpdate.pi-exa-mcp >&2
        nix-update pen-pi.extensionsUpdate.pi-hashline-edit-pro --version=branch >&2
        nix-update pen-pi.extensionsUpdate.pi-superpowers --version=branch >&2

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
            else printf "[{\"commitMessage\":\"pen-pi: %s\"}]\n", msg
          }'
      '';
      supportedFeatures = [ "commit" ];
    };
  };
}
