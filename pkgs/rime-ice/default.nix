{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-ice";
  version = "unstable-2023-02-14";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "3061144c4635dd84f854c2228c024875888b702e";
    sha256 = "0arffxhsdqcjgbcydyfs99i00iig2lm88m7krbr0z594jmbckym9";
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
