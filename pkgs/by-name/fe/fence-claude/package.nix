{
  lib,
  stdenv,
  fence-agent,
  claude-code,
  fetchFromGitHub,
  claudePlugins ? [
    (fetchFromGitHub {
      owner = "obra";
      repo = "superpowers";
      rev = "v5.1.0";
      hash = "sha256-3E3rO6hR87JUfS3XV1Eaoz6SDWOftleWvN9UPNFEMjw=";
    })
  ],
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
      lib.concatMapStringsSep " " (p: "--plugin-dir ${p}") claudePlugins
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
}
