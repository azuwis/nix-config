{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.09.25-unstable-2024-11-17";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "728dcc5051a62b5b481cd52126eaecf3408d8f72";
    sha256 = "sha256-riM18c1fcEP5N/0jAcrpqrqF9ldNA8JMnd3gSV20Odk=";
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
