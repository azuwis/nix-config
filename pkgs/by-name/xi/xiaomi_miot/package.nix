{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.6-unstable-2026-11-17";

  src = old.src.override {
    rev = "f5161ae20d3602fbf0a8e6ef5f83a1dc8ad046b0";
    hash = "sha256-tzqyoVSEsQroNSAmLBIkn7Cu3avf0lssZcqNt5vHrP4=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
