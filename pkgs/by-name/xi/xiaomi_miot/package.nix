{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.5-unstable-2026-10-23";

  src = old.src.override {
    rev = "f78158257e19a21902adaf6bcc8440c3ba172a91";
    hash = "sha256-+HmTZdnWWUkWqlQ32hjeRkHoEJxmoaI1FOrX9Qs7Yf0=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
