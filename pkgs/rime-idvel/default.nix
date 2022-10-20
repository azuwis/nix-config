{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-idvel";
  version = "unstable-2022-10-19";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "424eae48baff4028b7aa92cb4c1433f6333977b5";
    sha256 = "0y3vamj4fbrc4crcvizazf9zw4r168p7akmz66p1rk7cimr1z247";
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
