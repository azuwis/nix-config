{
  pen,
  codex,
}:

pen {
  name = "pen-codex";
  agentPackage = codex;
  agentWrapperArgs = [
    "--add-flags"
    "--config analytics.enabled=false --config check_for_update_on_startup=false --dangerously-bypass-approvals-and-sandbox"
  ];
  allowWrite = [
    "."
    "~/.codex"
  ];
}
