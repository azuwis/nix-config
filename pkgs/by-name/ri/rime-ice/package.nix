{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.05.21-unstable-2024-06-28";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "11e8efc19447dabf896b82e6e30ee47b3c8886e8";
    sha256 = "sha256-cohmeklyV7ReldN7RsHoj7+RQELjZCR+tnsdeFOWDds=";
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
