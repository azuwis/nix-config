{
  fence-agent,
  ainovel-cli,
}:

# Network access: configure in ~/.config/fence/fence.json, e.g.:
# {
#   "network": {
#     "allowedDomains": ["api.openai.com", "api.anthropic.com"]
#   }
# }

fence-agent {
  name = "fence-ainovel";
  agentPackage = ainovel-cli;
  allowWrite = [
    "."
    "~/.ainovel"
  ];
  preExecScript = ''
    mkdir -p ~/.ainovel
  '';
}
