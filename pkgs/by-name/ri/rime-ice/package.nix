{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.12.12-unstable-2025-02-20";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "65f915247295ca8097d29f36afa2927740558c7a";
    sha256 = "sha256-xzAPMRVBjR+0S7nGO9TBJmf5ZaFB49nB0Od9gU1jsh4=";
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
