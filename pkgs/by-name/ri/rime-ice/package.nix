{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.09.25-unstable-2024-11-23";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "c68d2780dc022058a0fdd0357be66eaaa8216f72";
    sha256 = "sha256-R6WtyA0LhonNi+LECculCsXqIW2UyXJNQ5D8jnYvpa0=";
  };

  installPhase = ''
    mkdir $out/
    cp -r cn_dicts/ $out/
    sed '/^\.\.\.$/q' rime_ice.dict.yaml > $out/rime_ice.dict.yaml
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Rime pinyin dict from iDvel";
    homepage = "https://github.com/iDvel/rime-ice";
  };
}
