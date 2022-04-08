{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-idvel";
  version = "unstable-2022-04-01";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-settings";
    rev = "c5a3db390ea3a9f0f8df83d9835aa0be1ea0f312";
    sha256 = "1f5a89vg4r10l3lz20hh432i25gfw2n6dc301xf6h654gnpvv3xj";
  };

  installPhase = ''
    mkdir $out/
    sed -i -e '/cn_dicts\/private/d' pinyin_simp.dict.yaml
    cp -r cn_dicts/ pinyin_simp.dict.yaml $out/
  '';

  meta = with lib; {
    description = "Rime pinyin dict from iDvel";
    homepage = "https://github.com/iDvel/rime-settings";
  };
}
