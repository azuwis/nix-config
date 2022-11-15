{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "rime-ice";
  version = "unstable-2022-11-11";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "a248857be0f750f90bc4f9c4e0c76ebff678e20e";
    sha256 = "1vdyh3dbf0mjlxqrvb1mnqfh63pxd7cq8h1askp18qg6chnxbzvy";
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
