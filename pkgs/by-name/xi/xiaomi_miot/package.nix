{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "1.1.5-unstable-2026-10-30";

  src = old.src.override {
    rev = "fdcbf875c1d111c6320ab85d096170d49eb69cc3";
    hash = "sha256-GDBHw0WSY+nkc7FMiwLFsFI1FzZ+5Vk16lxM8jyfOX8=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
  };
})
