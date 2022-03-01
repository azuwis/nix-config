{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-idvel";
  version = "unstable-2022-03-01";
  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-settings";
    rev = "e367add5e0c6dbbc7f150ff9e63fbf6ba1e7d0a9";
    sha256 = "0z0p4vclb6y1iz17jlz275zhcyyl642bx3nnfzhxjr61xg94ydi1";
  };
  installPhase = ''
    mkdir $out/
    sed -i -e '/cn_dicts\/av/d' -e '/cn_dicts\/private/d' pinyin_simp.dict.yaml
    cp pinyin_simp.dict.yaml $out/
    mkdir $out/cn_dicts
    cp cn_dicts/8105.dict.yaml cn_dicts/sys*.dict.yaml $out/cn_dicts/
  '';
}
