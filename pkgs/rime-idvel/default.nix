{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-idvel";
  version = "unstable-2022-06-15";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "1a87095c5f1b33ae3f22bc793c04f6a2390790bd";
    sha256 = "0ax6m2vygak7k83ml7idp4j4bwf9q1abb5kq7h2x4sl1mk31f044";
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
