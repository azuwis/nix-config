{ home-assistant-custom-components, nix-update-script }:

home-assistant-custom-components.xiaomi_gateway3.overridePythonAttrs (old: {
  version = "4.0.5-unstable-2024-09-01";

  src = old.src.override {
    rev = "b5c40bd96fdc60023ea8e69af740814f8a42549d";
    hash = "sha256-BkylAqIqI22jHeq5CnZxgIepK7Al9ABgvJOqutceD9k=";
  };

  passthru.isHomeAssistantComponent = true;
  # https://github.com/AlexxIT/XiaomiGateway3/pull/1436
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=pull/1436/head" ]; };
})
