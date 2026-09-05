{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.4-unstable-2026-09-05";

  src = old.src.override {
    rev = "fbcc1d31ee939a306001d67bad318b0a28924734";
    hash = "sha256-C83lpUfiRquH5hMRlY4VUx2ziAOIaaGg2+wMhfk5FNM=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
