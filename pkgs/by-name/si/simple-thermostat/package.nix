{
  lib,
  stdenvNoCC,
  fetchurl,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "simple-thermostat";
  version = "2.5.0";

  src = fetchurl {
    url = "https://github.com/nervetattoo/simple-thermostat/releases/download/v${finalAttrs.version}/simple-thermostat.js";
    hash = "sha256-mC7/6MsVrLkNgkls6VDAaCgHTzw5noYV+VOeCy6y+Xo=";
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
