{
  lib,
  stdenvNoCC,
  fetchurl,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "simple-thermostat";
  version = "4.2.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchurl {
    url = "https://github.com/Wheemer/simple-thermostat/releases/download/v${finalAttrs.version}/simple-thermostat.js";
    hash = "sha256-r17qy+a9zvCrhRWm3PL3dNNRxMWluljMM7kwgNUAaDs=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir $out
    cp $src $out/simple-thermostat.js
  '';

  passthru.entrypoint = "simple-thermostat.js";
  passthru.updateScript = nix-update-script {
    # Releases end with .0, others are pre-releases
    extraArgs = [ "--version-regex=^v([0-9.]+\.0)$" ];
  };

  meta = {
    description = "A different take on the thermostat card for Home Assistant";
    homepage = "https://github.com/Wheemer/simple-thermostat";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ azuwis ];
  };
})
