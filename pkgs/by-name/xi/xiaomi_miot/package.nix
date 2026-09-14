{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.5-unstable-2026-09-14";

  src = old.src.override {
    rev = "50f9fc31ca760615864336bc0e79eaea789d7324";
    hash = "sha256-HOO7jgL8KcI462YWvesZWfkTzY9xAQ/cy1S+0yamujA=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
