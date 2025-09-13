{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.0b0";

  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-Pek05/anDeA37lrQqZRK8gI3+sCJCYOv343ccb8tMfM=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
