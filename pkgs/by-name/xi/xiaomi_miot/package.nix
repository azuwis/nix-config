{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.5-unstable-2026-09-25";

  src = old.src.override {
    rev = "9783ce3144bd2ae111cef4b51b1027dc9bc062f4";
    hash = "sha256-jSn74kS74+j1cnM3/6XJRFoedR937wjwoNw9t/Ko6A4=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
