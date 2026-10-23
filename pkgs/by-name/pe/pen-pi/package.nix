{
  lib,
  stdenvNoCC,
  buildNpmPackage,
  fetchFromGitHub,
  linkFarm,
  pen,
  pi-coding-agent,
  runCommandLocal,
  writeScript,
  piExtensions ? {
    # pi-hashline-edit-pro = buildNpmPackage (finalAttrs: {
    #   pname = "pi-hashline-edit-pro";
    #   version = "0-unstable-2026-08-02";
    #   src = fetchFromGitHub {
    #     owner = "YuGiMob";
    #     repo = "pi-hashline-edit-pro";
    #     rev = "f8e0dee01f81b6052332655999cb6e77caf799fd";
    #     hash = "sha256-MUBvhRadnCbkOJNeIlSLJIDR/Fky5BuJ77pjjEAIW9E=";
    #   };
    #   npmDepsHash = "sha256-0/1qawTVnkYp8RMapioAwQOulhWjpUkTt+gwrHxF+/A=";
    #   npmInstallFlags = [
    #     "--omit=dev"
    #     "--omit=peer"
    #   ];
    #   dontNpmBuild = true;
    #   installPhase = ''
    #     runHook preInstall
    #     cp -r . $out
    #     runHook postInstall
    #   '';
    # });
    pi-monorepo-subagent = runCommandLocal "pi-monorepo-subagent" { } ''
      cp -r ${pi-coding-agent}/lib/node_modules/pi-monorepo/examples/extensions/subagent $out
      chmod -R u+w $out
      sed -i '/^model: /d' $out/agents/*.md
      cat > $out/package.json <<'EOF'
      {
        "name": "pi-monorepo-subagent",
        "type": "module",
        "pi": {
          "extensions": ["./index.ts"],
          "prompts": ["./prompts/*.md"]
        }
      }
      EOF
      substituteInPlace $out/agents.ts \
        --replace-fail \
          'const userAgents = scope === "project" ? [] : loadAgentsFromDir(userDir, "user");' \
          'const userAgents = scope === "project" ? [] : [...loadAgentsFromDir("'"$out/agents"'", "user"), ...loadAgentsFromDir(userDir, "user")];'
    '';
    superpowers =
      let
        version = "7.0.1";
      in
      {
        inherit version;
      }
      // fetchFromGitHub {
        owner = "obra";
        repo = "superpowers";
        tag = "v${version}";
        hash = "sha256-9+69YEdjdaDu5sWTyAbufSVcZgGD7h6wAq4nUVY2syE=";
      };
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
    # pi can't handle `pi --extension ... <subcommand>`. `set --` rewrites the
    # "$@" that the wrapper's final `exec pi "$@"` uses.
    "--run"
    ''
      case "$1" in
        auth|config|install|list|mcp|remove|uninstall|update) ;;
        *) set -- ${
          lib.concatMapAttrsStringSep " " (name: _: "--extension ${extensionsDir}/${name}") piExtensions
        } "$@" ;;
      esac
    ''
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

        # nix-update pen-pi.extensionsUpdate.pi-hashline-edit-pro --version=branch >&2
        nix-update pen-pi.extensionsUpdate.superpowers >&2

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
