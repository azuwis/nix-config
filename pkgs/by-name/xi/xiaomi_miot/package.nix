{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.5-unstable-2026-11-07";

  src = old.src.override {
    rev = "d6e6dfc8d2de409972a7683c93bbf3fa0119370c";
    hash = "sha256-Cutqye8lzlk1WGdW+VbTcUqOMWeG7moRSAAT2hIoiB0=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
