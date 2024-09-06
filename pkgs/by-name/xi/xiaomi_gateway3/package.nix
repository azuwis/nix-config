{ home-assistant-custom-components }:

home-assistant-custom-components.xiaomi_gateway3.overridePythonAttrs (old: rec {
  version = "4.0.6";
  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-E3BekX0Xbp1R36+dYmOlsI2BTrdGjFsMoYYRIiBi1qU=";
  };
})
