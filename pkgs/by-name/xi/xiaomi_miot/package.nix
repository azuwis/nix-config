{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.0.20-unstable-2025-08-14";

  src = old.src.override {
    rev = "eefbc2d91473e8c401def588c7011abfc1fd80fe";
    hash = "sha256-Qb/3yzVDlMTaYA1IMcj+639r03Ega/dMtAKtGidCwNw=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
