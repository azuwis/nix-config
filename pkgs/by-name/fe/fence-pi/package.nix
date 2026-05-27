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
  preExecScript = "mkdir -p ~/.pi";
}
