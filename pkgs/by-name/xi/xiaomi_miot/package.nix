{ home-assistant, home-assistant-custom-components }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "0.7.23";

  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-PTjkKuK+DAOmKREr0AHjFXzy4ktguD4ZOHcWuLedLH0=";
  };

  passthru.skipUpdate = true;

  meta.changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
})
