{
  lib,
  stdenvNoCC,
  fence-agent,
  claude-code,
  fetchFromGitHub,
  writeScript,
  writeText,
  claudePlugins ? {
    mattpocock-skills =
      let
        version = "1.1.0";
      in
      {
        inherit version;
      }
      // fetchFromGitHub {
        owner = "mattpocock";
        repo = "skills";
        tag = "v${version}";
        hash = "sha256-XqF709Y9GMKINzZITlbCTyatG9AxRZh0qn2vcv1Z8yo=";
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
        version = "6.1.1";
      in
      {
        inherit version;
      }
      // fetchFromGitHub {
        owner = "obra";
        repo = "superpowers";
        tag = "v${version}";
        hash = "sha256-kHdQ9e44doBk2yYW88tMSCqVG8ycYcvJSZlrIziXhpA=";
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

# Network access: configure in ~/.config/fence/fence.json, e.g.:
# {
#   "network": {
#     "allowedDomains": ["*.anthropic.com"],
#     "deniedDomains": ["statsig.anthropic.com", "*.sentry.io"]
#   }
# }
#
# NixOS security wrapper example (for CAP_BPF):
# security.wrappers.claude = {
#   source = "${lib.getExe pkgs.fence-claude}";
#   owner = "root";
#   group = "wheel";
#   permissions = "u+rx,g+x";
#   capabilities = "cap_bpf+ep";
# };

let
  claudeSettingsJson = writeText "claude-settings.json" (builtins.toJSON claudeSettings);
in

fence-agent {
  name = "fence-claude";
  agentPackage = claude-code;
  agentWrapperArgs = [
    "--add-flags"
    "--dangerously-skip-permissions --effort max --settings ${claudeSettingsJson} ${
      lib.concatMapAttrsStringSep " " (_: p: "--plugin-dir ${p}") claudePlugins
    }"
  ]
  # /tmp is not writable on darwin, set CLAUDE_CODE_TMPDIR to workaround
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "--run"
    ''export CLAUDE_CODE_TMPDIR="$HOME/.claude/tmp"''
  ];
  allowWrite = [
    "."
    "~/.claude"
    "~/.claude.json"
  ];
  # hasCompletedOnboarding skips the onboarding flow, which would fail
  # with ERR_BAD_REQUEST inside the sandbox due to no network access.
  preExecScript = ''
    if [ ! -f ~/.claude.json ]; then
      echo '{"hasCompletedOnboarding": true}' > ~/.claude.json
    fi
    mkdir -p ~/.claude
  '';
  extraPassthru = {
    pluginsUpdate = builtins.mapAttrs (
      name: plugin:
      if plugin ? src then
        plugin
      else
        stdenvNoCC.mkDerivation {
          pname = "claude-plugin-${name}";
          version = plugin.version or "0";
          src = plugin;
        }
    ) claudePlugins;
    updateScript = {
      command = writeScript "update-fence-claude" ''
        #!/usr/bin/env nix-shell
        #!nix-shell -i bash -p gawk gitMinimal nix-update

        set -euo pipefail

        nix-update fence-claude.pluginsUpdate.mattpocock-skills >&2
        nix-update fence-claude.pluginsUpdate.ponytail >&2
        nix-update fence-claude.pluginsUpdate.superpowers >&2

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
            else printf "[{\"commitMessage\":\"fence-claude: %s\"}]\n", msg
          }'
      '';
      supportedFeatures = [ "commit" ];
    };
  };
}
