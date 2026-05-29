{
  lib,
  stdenvNoCC,
  fetchurl,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "simple-thermostat";
  version = "3.1.3";

  src = fetchurl {
    url = "https://github.com/Wheemer/simple-thermostat/releases/download/v${finalAttrs.version}/simple-thermostat.js";
    hash = "sha256-osc6qANehx0AD85tFq1vf60U+6OmjvSdx/p+GQcD3ms=";
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
    homepage = "https://github.com/Wheemer/simple-thermostat";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ azuwis ];
  };
})
