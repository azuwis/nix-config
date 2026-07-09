{
  pen,
  gemini-cli,
  geminiSettings ? {
    general = {
      enableAutoUpdate = false;
      enableAutoUpdateNotification = false;
    };
    privacy.usageStatisticsEnabled = false;
  },
}:

let
  geminiSettingsJson = builtins.toFile "gemini-settings.json" (builtins.toJSON geminiSettings);
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
