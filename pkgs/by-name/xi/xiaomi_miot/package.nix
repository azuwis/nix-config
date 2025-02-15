{ home-assistant-custom-components }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.0.10b0";

  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-y3D7WeqFI3IldfsR8OVDbc7St+8VQtf6yhvLztiZ8+8=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
