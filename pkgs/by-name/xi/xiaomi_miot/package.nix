{
  home-assistant-custom-components,
  fetchpatch,
  nix-update-script,
}:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.2";

  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-S1rkrNf1rV9TDjcAfFxFj/IlHMngjp4qysx+8pN0TdI=";
  };

  patches = (old.patches or [ ]) ++ [
    # https://github.com/al-one/hass-xiaomi-miot/issues/2688
    (fetchpatch {
      url = "https://github.com/al-one/hass-xiaomi-miot/commit/f130bd155ef8cb128fe7790ca51468740b7232f2.patch";
      hash = "sha256-NAHqUC9VOhn96lJdPLmwBUvS489CX/g4is+5pZau80k=";
    })
  ];

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version-regex=^v([0-9.]+)$" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
