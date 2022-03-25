{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-idvel";
  version = "unstable-2022-03-16";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-settings";
    rev = "9e637e1287f89f38bf82aeeefd70aa7d5a388be3";
    sha256 = "1nxa2dnhfhs54y2p4zi7rkkm3954j9pzs7mx3bjz83spbssim5af";
  };

  installPhase = ''
    mkdir $out/
    sed -i -e '/cn_dicts\/av/d' -e '/cn_dicts\/private/d' pinyin_simp.dict.yaml
    cp pinyin_simp.dict.yaml $out/
    mkdir $out/cn_dicts
    cp cn_dicts/8105.dict.yaml cn_dicts/sys*.dict.yaml $out/cn_dicts/
  '';

  meta = with lib; {
    description = "Rime pinyin dict from iDvel";
    homepage = "https://github.com/iDvel/rime-settings";
  };
}
