{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.4-unstable-2026-07-30";

  src = old.src.override {
    rev = "17945db6b2f1f02249be49dfda14ae650263a2ca";
    hash = "sha256-57vcF6UpD4r+cMRWDFjg8uXXOdT3hHj1vYpCrlnEldY=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
