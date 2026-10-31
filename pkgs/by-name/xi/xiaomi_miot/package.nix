{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.5-unstable-2026-10-31";

  src = old.src.override {
    rev = "75bc74f67275bde6a8742b6638039819e10eaea5";
    hash = "sha256-poYuxRKAoQUKNv2+AFFMwm5mkOioEzv1/O2LYieI0hw=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
