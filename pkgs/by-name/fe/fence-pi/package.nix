{
  lib,
  stdenv,
  fence-agent,
  fetchFromGitHub,
  pi-coding-agent,
  writeScript,
  piExtensions ? {
    pi-exa-mcp = {
      version = "2026-06-08";
    }
    // fetchFromGitHub {
      owner = "ben-vargas";
      repo = "pi-packages";
      tag = "2026-06-08";
      rootDir = "packages/pi-exa-mcp";
      hash = "sha256-Wqw+Gp7skL5S4xB9Ktq9rs6F6ulA1XAuXb9PKe2pQV0=";
    };
    pi-hashline-edit = fetchFromGitHub {
      owner = "JoshMock";
      repo = "the-agency";
      tag = "pi-hashline-edit-v0.2.1";
      rootDir = "packages/hashline-edit";
      hash = "sha256-iIR2+7GD1aH+AXKYHcpA0ZKW3283GIXq+YQO/5X0V1A=";
    };
    pi-superpowers = {
      version = "0-unstable-2026-03-05";
    }
    // fetchFromGitHub {
      owner = "coctostan";
      repo = "pi-superpowers";
      rev = "efe1d158691bf064c24f0460fd4e46ca58de0055";
      hash = "sha256-cwGs/Hdbk3h9Yk+vEMtXSyAgy+grxEc6eZAHZZjpcDk=";
    };
  },
}:

# Network access: configure in ~/.config/fence/fence.json, e.g.:
# {
#   "network": {
#     "allowedDomains": ["your.api.address"],
#     "deniedDomains": ["*.sentry.io"]
#   }
# }

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
    "--extension ${pi-coding-agent}/lib/node_modules/pi-monorepo/examples/extensions/subagent ${
      lib.concatMapAttrsStringSep " " (_: p: "--extension ${p}") piExtensions
    }"
  ];
  preExecScript = ''
    mkdir -p ~/.pi
  '';
  extraPassthru = {
    extensionsUpdate = builtins.mapAttrs (
      name: plugin:
      stdenv.mkDerivation {
        pname = "pi-plugin-${name}";
        version = plugin.version or "0";
        src = plugin;
      }
    ) piExtensions;
    updateScript = writeScript "update-fence-pi-plugins" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p nix-update

      set -eu -o pipefail

      nix-update fence-pi.extensionsUpdate.pi-exa-mcp
      nix-update fence-pi.extensionsUpdate.pi-superpowers --version=branch
    '';
  };
}
