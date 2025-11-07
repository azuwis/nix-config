{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.1-unstable-2025-11-04";

  src = old.src.override {
    # rev = "v${version}";
    rev = "4b5a8682b75c870eb6116bd07c3288906a6f04a7";
    hash = "sha256-0B+rG2h2OMb363t0529/XjqZ9ORaT7XXk4qVyEAfNx8=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    # updateScript = nix-update-script { extraArgs = [ "--version-regex=^v([0-9.]+)$" ]; };
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
