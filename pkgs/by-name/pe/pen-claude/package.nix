{
  lib,
  stdenv,
  pen,
  claude-code,
  fetchFromGitHub,
  writeScript,
  claudePlugins ? {
    mattpocock-skills =
      let
        version = "1.0.1";
      in
      {
        inherit version;
      }
      // fetchFromGitHub {
        owner = "mattpocock";
        repo = "skills";
        tag = "v${version}";
        hash = "sha256-nuHQ+SG5UerKs334Yk5nsxHOncGXQKF1yVdnwwVpLZ8=";
      };
    ponytail =
      let
        version = "4.8.4";
      in
      {
        inherit version;
      }
      // fetchFromGitHub {
        owner = "DietrichGebert";
        repo = "ponytail";
        tag = "v${version}";
        hash = "sha256-1A9GkjCuiqwd6Wxl18CZUGYekxrbeTLVDapNUua8ihg=";
      };
    superpowers =
      let
        version = "6.0.3";
      in
      {
        inherit version;
      }
      // fetchFromGitHub {
        owner = "obra";
        repo = "superpowers";
        tag = "v${version}";
        hash = "sha256-+lT2a/qq0SF4k0PgnEDKiuidVlZX2p0vEso4d/5T1os=";
      };
  },
  claudeSettings ? {
    attribution = {
      commit = "";
      pr = "";
    };
    effortLevel = "xhigh";
    env = {
      CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
      CLAUDE_CODE_WORKFLOWS = "1";
    };
    statusLine = {
      type = "command";
      command = ./statusline.jq;
    };
    skipDangerousModePermissionPrompt = true;
    skipWebFetchPreflight = true;
  },
}:

let
  claudeSettingsJson = builtins.toFile "claude-settings.json" (builtins.toJSON claudeSettings);
in

pen {
  name = "pen-claude";
  agentPackage = claude-code;
  agentWrapperArgs = [
    "--add-flags"
    "--dangerously-skip-permissions --effort max --settings ${claudeSettingsJson} ${
      lib.concatMapAttrsStringSep " " (_: p: "--plugin-dir ${p}") claudePlugins
    }"
  ];
  allowWrite = [
    "."
    "~/.claude"
    "~/.claude.json"
  ];
  extraPassthru = {
    pluginsUpdate = builtins.mapAttrs (
      name: plugin:
      if plugin ? src then
        plugin
      else
        stdenv.mkDerivation {
          pname = "claude-plugin-${name}";
          version = plugin.version or "0";
          src = plugin;
        }
    ) claudePlugins;
    updateScript = {
      command = writeScript "update-pen-claude" ''
        #!/usr/bin/env nix-shell
        #!nix-shell -i bash -p gawk gitMinimal nix-update

        set -euo pipefail

        nix-update pen-claude.pluginsUpdate.mattpocock-skills >&2
        nix-update pen-claude.pluginsUpdate.ponytail >&2
        nix-update pen-claude.pluginsUpdate.superpowers >&2

        git diff HEAD | awk '
          /^ +[a-z][-a-z0-9]* =$/       { name = $1 }
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
            else printf "[{\"commitMessage\":\"pen-claude: %s\"}]\n", msg
          }'
      '';
      supportedFeatures = [ "commit" ];
    };
  };
}
