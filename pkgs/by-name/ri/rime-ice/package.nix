{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.05.21-unstable-2024-06-23";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "fdb6141a18ed6479fd82616c8a82befea2ae30df";
    sha256 = "sha256-O1oR85+0qo3GFluV6Z5rYuycUCErhZHOc1rrdD2Yh5k=";
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
