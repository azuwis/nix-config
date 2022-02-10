{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-idvel";
  version = "unstable-2022-02-06";
  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-settings";
    rev = "55195eb4dfc957cb319c1740db2791e773ef76e6";
    sha256 = "1a934rnag99b4vhqbkybcnl4k89wk2wr30w1iwbd9x9v9pspdyi0";
  };
  installPhase = ''
    mkdir $out/
    sed -i -e '/cn_dicts\/av/d' -e '/cn_dicts\/private/d' pinyin_simp.dict.yaml
    cp pinyin_simp.dict.yaml $out/
    mkdir $out/cn_dicts
    cp cn_dicts/8105.dict.yaml cn_dicts/sys*.dict.yaml $out/cn_dicts/
  '';
}
