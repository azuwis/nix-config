{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-idvel";
  version = "unstable-2022-06-12";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-settings";
    rev = "68ed82581e9a554af1cf4869f84a26d895d42132";
    sha256 = "178ai7myr8a83iiykl9sw9vandj3nkd89vrwzxw9x67cib91nmig";
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
