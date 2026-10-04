{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.5-unstable-2026-10-04";

  src = old.src.override {
    rev = "a3a07b8504bacfee114a6052ae864d7dd149bf71";
    hash = "sha256-7kHMopjK7g+Cm7x3/MSsWy8NJvIG/VwFesEkUU+ROLE=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
