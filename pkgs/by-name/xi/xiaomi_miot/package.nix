{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.0.19-unstable-2025-07-03";

  src = old.src.override {
    rev = "aa99f3885405ede068dd117b5b2657184586ddcb";
    hash = "sha256-kifImeiytb7t+eyRCmHKPR+IkXkpsRKg0yikIQLX+40=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
