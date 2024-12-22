{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.12.12-unstable-2024-12-21";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "7e1faeac9ad8f37c64de0c73ab7340dfb80bf818";
    sha256 = "sha256-hYolk8XFZbswM732hlz2WnGGrT41QtDURnzb+pHl1KA=";
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
