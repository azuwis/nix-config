{ home-assistant-custom-components }:

home-assistant-custom-components.xiaomi_gateway3.overrideAttrs (old: rec {
  name = builtins.replaceStrings [ old.version ] [ version ] old.name;
  version = "4.0.4";

  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-MQ/yxxXt2BXUAHEHGOaqansgon22oQ0byCQcUcVZdOQ=";
  };

  # Skip from update.nix
  passthru = { };
})
