{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-idvel";
  version = "unstable-2022-08-28";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "32406dba79e0b01d0dde2a54c3c588ef3f944adb";
    sha256 = "1mskvig5wgm6fkjq2by11zb4v59v5dnv1m9qnkb3f88qglvqk96v";
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
