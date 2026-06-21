{
  lib,
  stdenv,
  fence-agent,
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
  claudeSettingsJson = builtins.toFile "claude-settings.json" (builtins.toJSON claudeSettings);
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
        stdenv.mkDerivation {
          pname = "claude-plugin-${name}";
          version = plugin.version or "0";
          src = plugin;
        }
    ) claudePlugins;
    updateScript = writeScript "update-eden" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p nix-update

      set -eu -o pipefail

      nix-update fence-claude.pluginsUpdate.mattpocock-skills
      nix-update fence-claude.pluginsUpdate.superpowers
    '';
  };
}
