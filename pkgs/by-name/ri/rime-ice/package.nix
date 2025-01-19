{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.12.12-unstable-2025-01-18";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "e8d30d4b153fee281ab7f10c8c3f53c3f1a4ce23";
    sha256 = "sha256-w5at0mROFy+d5cyDJN7n87U7iIhKk0NvlgzII+J6LD4=";
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
