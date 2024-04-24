{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "unstable-2023-11-25";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "b56953bd884c63d5edf0ef017dec64c4192318ef";
    sha256 = "0nj3qnd9mhnr9qfxqyp24ikx4ywy43gy4vijl9b9xb5d1fpqmn8f";
  };

  installPhase = ''
    mkdir $out/
    cp -r cn_dicts/ $out/
    sed '/^\.\.\.$/q' rime_ice.dict.yaml > $out/rime_ice.dict.yaml
  '';

  meta = with lib; {
    description = "Rime pinyin dict from iDvel";
    homepage = "https://github.com/iDvel/rime-ice";
  };
}
