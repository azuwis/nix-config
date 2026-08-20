{
  pen,
  deepseek-harness,
}:

pen {
  name = "pen-dsh";
  agentPackage = deepseek-harness;
  agentWrapperArgs = [
    "--set"
    "DSH_PERMISSION_MODE"
    "danger-full-access"
    "--set"
    "DSH_TELEMETRY_DISABLED"
    "1"
    "--set"
    "NODE_USE_ENV_PROXY"
    "1"
  ];
  allowWrite = [
    "."
    "~/.dsh"
  ];
}
