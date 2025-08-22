{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.0.20";

  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-qn//le4zaS7URP4pWofwsA4FbB20DK7iRRUn8NWzwAI=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
