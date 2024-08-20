{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.05.21-unstable-2024-08-20";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "0407f13bfd45e8ed82b7f26fe0c9642635184cb6";
    sha256 = "sha256-OnXznPdxilrvMP/d1T9v8VQ2PeZ9xLHQzmNfLJl2bnA=";
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
