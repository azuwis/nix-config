{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.09.25-unstable-2024-09-25";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "ea74e40bec2bd6580fa8d807075cd107739ba6cd";
    sha256 = "sha256-R2K2LNycXqsUxXvMMq5fcQJUhDnhQMcTlvryMLeiKH0=";
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
