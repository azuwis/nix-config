{ home-assistant-custom-components }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "0.7.22";
  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-KRjhGvK69NTsH0AkmFAZD10g9CpGQtjAXLlOm40Y4k8=";
  };
})
