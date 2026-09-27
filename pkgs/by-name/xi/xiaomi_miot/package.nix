{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.5-unstable-2026-09-27";

  src = old.src.override {
    rev = "919b7a49bb3215a22ad56cbb5b6eea026c391691";
    hash = "sha256-LMvhnCSRvWmL5QjLuO+YW3j1swlQIRhOIQoSQMhrQ2w=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
