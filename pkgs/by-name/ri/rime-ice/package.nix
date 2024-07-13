{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.05.21-unstable-2024-07-03";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "37ca416a9c755716d049c549b131276ddc440688";
    sha256 = "sha256-uEE+KWkIjCvB/cuLNm94lFm7HLb9cCgFE7t6NCTVEoo=";
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
