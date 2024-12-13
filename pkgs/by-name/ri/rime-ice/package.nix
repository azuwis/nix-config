{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.12.12-unstable-2024-12-13";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "522ef78bf7ed567d3a1bd4f51d0991685e6a0f52";
    sha256 = "sha256-D6VcJWDnfhCHd3B/QR/Pot+6oNs6a77g8hWKU38nZgw=";
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
