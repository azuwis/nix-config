{
  lib,
  stdenvNoCC,
  fetchurl,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "simple-thermostat";
  version = "2.2.7";

  src = fetchurl {
    url = "https://github.com/nickdos/simple-thermostat/releases/download/v${finalAttrs.version}/simple-thermostat.js";
    hash = "sha256-kHVUWiYjEumdPUPxbs6GjRdwC988Z863OhXtuZ+ibCI=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir $out
    cp $src $out/simple-thermostat.js
  '';

  passthru.entrypoint = "simple-thermostat.js";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A different take on the thermostat card for Home Assistant";
    homepage = "https://github.com/nervetattoo/simple-thermostat";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ azuwis ];
  };
})
