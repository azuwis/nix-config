{
  pen,
  gemini-cli,
  writeText,
  geminiSettings ? {
    general = {
      enableAutoUpdate = false;
      enableAutoUpdateNotification = false;
    };
    privacy.usageStatisticsEnabled = false;
  },
}:

let
  geminiSettingsJson = writeText "gemini-settings.json" (builtins.toJSON geminiSettings);
in

pen {
  name = "pen-gemini";
  agentPackage = gemini-cli;
  agentWrapperArgs = [
    "--set"
    "GEMINI_CLI_SYSTEM_SETTINGS_PATH"
    "${geminiSettingsJson}"
  ];
  allowWrite = [
    "."
    "~/.gemini"
  ];
}
