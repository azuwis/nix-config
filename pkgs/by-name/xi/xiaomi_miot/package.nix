{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.5-unstable-2026-09-09";

  src = old.src.override {
    rev = "509ebe8d23cbdc9e6486a8f74baddfbfce10c7c7";
    hash = "sha256-F3lNXQ+aIRavZUNdViFUtJt3gus5dqo4idcbQcopE7M=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
