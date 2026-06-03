{ home-assistant-custom-components }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.4";

  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-t1kOPiZR0CxOsp2V4cJNi+aiDdr7VhqhX8jOAiKTemk=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
