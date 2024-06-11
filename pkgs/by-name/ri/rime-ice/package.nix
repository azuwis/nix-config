{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-ice";
  version = "2024.05.21-unstable-2024-06-09";

  src = fetchFromGitHub {
    owner = "iDvel";
    repo = "rime-ice";
    rev = "0b59306d619a29cd345e3277aa5cd0b0d5653eda";
    sha256 = "sha256-dElBA0baKaMN04sSXvMgfey+I60Zq4b+i+KoYzpxZMQ=";
  };

  installPhase = ''
    mkdir $out/
    cp -r cn_dicts/ $out/
    sed '/^\.\.\.$/q' rime_ice.dict.yaml > $out/rime_ice.dict.yaml
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = with lib; {
    description = "Rime pinyin dict from iDvel";
    homepage = "https://github.com/iDvel/rime-ice";
  };
}
