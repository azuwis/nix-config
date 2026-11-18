{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.6-unstable-2026-11-18";

  src = old.src.override {
    rev = "8ac4df7005aefb6a92ae5f66f53fa56e2e548c16";
    hash = "sha256-8dtgBXJeQZs6gBKsE1oUpMNM4jd0VZzH6Vz4VBEFLYw=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
