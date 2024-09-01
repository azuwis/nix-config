{ home-assistant-custom-components, fetchpatch }:

home-assistant-custom-components.xiaomi_gateway3.overridePythonAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    (fetchpatch {
      # https://github.com/AlexxIT/XiaomiGateway3/issues/1351
      url = "https://github.com/azuwis/XiaomiGateway3/commit/4cef7f381af88ee0f2e8d6a3bf42cfe507187ea5.patch";
      hash = "sha256-lGHGUHL+T2QYBqYYAlRRdRa8ZVUvyGxHVhfwfWbD6iU=";
    })
  ];
})
