{ home-assistant, home-assistant-custom-components }:

home-assistant-custom-components.xiaomi_miot.overridePythonAttrs (old: rec {
  version = "0.7.24";
  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-DI2e3JBOyBUIUtEYS9ygR3B/XvpB5h6RrBdnNJiwyfY=";
  };
  propagatedBuildInputs = with home-assistant.python.pkgs; [
    construct
    micloud
    python-miio
  ];
})
