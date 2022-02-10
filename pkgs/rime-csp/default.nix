{ stdenvNoCC, fetchFromGitHub, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-csp";
  version = "unstable-2022-02-06";
  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-settings";
    rev = "55195eb4dfc957cb319c1740db2791e773ef76e6";
    sha256 = "1a934rnag99b4vhqbkybcnl4k89wk2wr30w1iwbd9x9v9pspdyi0";
  };
  hans = fetchurl {
    url = "https://github.com/lotem/rime-octagram-data/raw/hans/zh-hans-t-essay-bgw.gram";
    sha256 = "0ygcpbhp00lb5ghi56kpxl1mg52i7hdlrznm2wkdq8g3hjxyxfqi";
  };
  grammar = fetchurl {
    url = "https://github.com/lotem/rime-octagram-data/raw/master/grammar.yaml";
    sha256 = "0aa14rvypnja38dm15hpq34xwvf06al6am9hxls6c4683ppyk355";
  };
  schema = ./csp.schema.yaml;
  installPhase = ''
    mkdir $out/
    sed -i -e '/cn_dicts\/av/d' -e '/cn_dicts\/private/d' pinyin_simp.dict.yaml
    cp pinyin_simp.dict.yaml $out/
    mkdir $out/cn_dicts
    cp cn_dicts/8105.dict.yaml cn_dicts/sys*.dict.yaml $out/cn_dicts/
    cp ${hans} $out/zh-hans-t-essay-bgw.gram
    cp ${grammar} $out/grammar.yaml
    cp ${schema} $out/csp.schema.yaml
  '';
}
