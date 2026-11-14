{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.6-unstable-2026-11-14";

  src = old.src.override {
    rev = "2894ca80d0ce2432dbee36870a892d393d80330e";
    hash = "sha256-DYFx/7r/6sTARWg4Ax5RlcGx9Rg1cOhGe24OzfFNL0s=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
