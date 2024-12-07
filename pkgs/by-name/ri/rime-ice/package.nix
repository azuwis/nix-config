{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.11.29-unstable-2024-12-07";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "a0aa1adc556e0cf70195140cc26085687b575f99";
    sha256 = "sha256-cEQsdPozclEWip4WTVxleFU5x9KMNXq3Y59vLIkT5Zs=";
  };

  installPhase = ''
    mkdir $out/
    cp -r cn_dicts/ $out/
    sed '/^\.\.\.$/q' rime_ice.dict.yaml > $out/rime_ice.dict.yaml
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Rime pinyin dict from iDvel";
    homepage = "https://github.com/iDvel/rime-ice";
  };
}
