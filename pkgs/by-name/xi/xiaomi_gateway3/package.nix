{ lib, home-assistant-custom-components }:

home-assistant-custom-components.xiaomi_gateway3.overridePythonAttrs (old: rec {
  version = "4.0.4";

  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-MQ/yxxXt2BXUAHEHGOaqansgon22oQ0byCQcUcVZdOQ=";
  };

  passthru.updateScript = "echo";
})
