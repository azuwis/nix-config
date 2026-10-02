{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.5-unstable-2026-09-30";

  src = old.src.override {
    rev = "3bb942ea24079dae8e0e95c4b1745b5263fc7443";
    hash = "sha256-FPunMWeeVZGNI0R45lbZaStpZ86A4ABRGrQzN7qLgZ8=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
