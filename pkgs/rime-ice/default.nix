{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-ice";
  version = "unstable-2023-05-09";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "3e24a1ee202054f776f188ba82e86fa30f16ab55";
    sha256 = "0gs470i7sx6gcs44mz5k15ik72i0zqkamf1pp0w9i8mrwnrgcapw";
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
