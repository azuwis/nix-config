{
  lib,
  stdenv,
  fence-agent,
  claude-code,
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

fence-agent {
  name = "fence-claude";
  agentPackage = claude-code;
  allowWrite = [
    "."
    "~/.claude"
    "~/.claude.json"
  ];
  agentArgs = "--dangerously-skip-permissions";
  # hasCompletedOnboarding skips the onboarding flow, which would fail
  # with ERR_BAD_REQUEST inside the sandbox due to no network access.
  preExecScript = ''
    if [ ! -f ~/.claude.json ]; then
      echo '{"hasCompletedOnboarding": true}' > ~/.claude.json
    fi
    mkdir -p ~/.claude
  '';
  extraWrapperArgs = [
    "--set"
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC"
    "1"
  ]
  # /tmp is not writable on darwin, set CLAUDE_CODE_TMPDIR to workaround
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "--run"
    ''export CLAUDE_CODE_TMPDIR="$HOME/.claude/tmp"''
  ];
}
