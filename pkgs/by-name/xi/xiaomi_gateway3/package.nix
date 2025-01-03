{ home-assistant-custom-components }:

home-assistant-custom-components.xiaomi_gateway3.overridePythonAttrs (old: rec {
  version = "4.0.8";

  src = old.src.override {
    rev = "v${version}";
    hash = "sha256-VvuvOUldhmROTs1+YbCT7++VJ71GgGKRbHjqZxQQY0w=";
  };

  passthru = (old.passthru or { }) // {
    enable = true;
  };

  meta = (old.meta or { }) // {
    changelog = "https://github.com/AlexxIT/XiaomiGateway3/releases/tag/v${version}";
  };
})
