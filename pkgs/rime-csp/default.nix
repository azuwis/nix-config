{ stdenvNoCC, fetchzip, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-csp";
  version = "0.1";
  src = fetchzip {
    url = "https://github.com/fkxxyz/rime-cloverpinyin/releases/download/1.1.4/clover.schema-1.1.4.zip";
    stripRoot = false;
    sha256 = "1920xga1m5sx7f9lc2x6hfny1y6hjmix164r6h3k1fjhjigwz2fz";
  };
  octagram = fetchurl {
    url = "https://github.com/lotem/rime-octagram-data/raw/hans/zh-hans-t-essay-bgw.gram";
    sha256 = "0ygcpbhp00lb5ghi56kpxl1mg52i7hdlrznm2wkdq8g3hjxyxfqi";
  };
  schema = ./csp.schema.yaml;
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir $out/
    cat <<EOF >> clover.dict.yaml
    ...
    ；	;
    EOF
    cp *.dict.yaml $out/
    cp ${octagram} $out/zh-hans-t-essay-bgw.gram
    cp ${schema} $out/csp.schema.yaml
  '';
}
