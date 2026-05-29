{
  fence-agent,
  pi-coding-agent,
}:

# Network access: configure in ~/.config/fence/fence.json, e.g.:
# {
#   "network": {
#     "allowedDomains": ["your.api.address"],
#     "deniedDomains": ["*.sentry.io"]
#   }
# }
#

fence-agent {
  name = "fence-pi";
  agentPackage = pi-coding-agent;
  allowWrite = [
    "."
    "~/.pi"
  ];
  extraWrapperArgs = [
    "--set"
    "PI_OFFLINE"
    "true"
    "--set"
    "PI_TELEMETRY"
    "false"
  ];
  preExecScript = ''
    mkdir -p ~/.pi
    agent_args+=(--extension "${pi-coding-agent}/lib/node_modules/pi-monorepo/examples/extensions/subagent")
  '';
}
