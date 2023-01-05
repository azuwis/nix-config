{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-ice";
  version = "unstable-2023-01-04";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "ed4f56ee83eda15333424993d15d7566600d106f";
    sha256 = "0n9jf7p0hfrfdxzvaiy3dia73bnws6ynzmdq2qzs6cs876cwcwx0";
  };

  installPhase = ''
    mkdir $out/
    cp -r cn_dicts/ rime_ice.dict.yaml $out/
  '';

  meta = with lib; {
    description = "Rime pinyin dict from iDvel";
    homepage = "https://github.com/iDvel/rime-ice";
  };
}
