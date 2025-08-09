{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.0.19-unstable-2025-07-27";

  src = old.src.override {
    rev = "e75efede61689c61bbf85056b2f32337a2d9c9e5";
    hash = "sha256-KwE6pizyb2QLqyFosQeH0sxgWYgqbEJyKe6VWg1GNLI=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
