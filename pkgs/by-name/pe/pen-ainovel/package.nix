{
  pen,
  ainovel-cli,
}:

pen {
  name = "pen-ainovel";
  agentPackage = ainovel-cli;
  allowWrite = [
    "."
    "~/.ainovel"
  ];
}
