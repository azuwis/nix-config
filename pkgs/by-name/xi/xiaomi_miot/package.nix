{
  home-assistant-custom-components,
  nix-update-script,
}:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.4";

  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-t1kOPiZR0CxOsp2V4cJNi+aiDdr7VhqhX8jOAiKTemk=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version-regex=^v([0-9.]+)$" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
