{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.12.12-unstable-2025-02-11";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "b8eb8d7bfee4cf55c761e809d49958eff3ba1687";
    sha256 = "sha256-Z0Mjh/FNS4ZwAvfFTp7m5uOrJzor5EfkTOnFYIf508I=";
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
