{ stdenvNoCC, fetchFromGitHub, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-csp";
  version = "0.1";
  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-settings";
    rev = "f161a97f81c170bc040ab2a635e4b75617ae52b2";
    sha256 = "sha256-GfeKg8J/oVEXhZiTo42ZcBEq+168EPzq11Ssqd5zoSI=";
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
