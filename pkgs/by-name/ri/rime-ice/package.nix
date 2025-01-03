{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.12.12-unstable-2024-12-29";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "7ed5167f0cbbc19b18c0a4eff084b49b86857c05";
    sha256 = "sha256-vrNmoPWzzbVUpHYxnuZhm+/AJV5t2M2975s0+mZiP2M=";
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
