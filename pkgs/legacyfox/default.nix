{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "legacyfox";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "girst";
    repo = "LegacyFox-mirror-of-git.gir.st";
    rev = "v${version}";
    sha256 = "sha256-3p6W/O8LfsIuAp/qFJFCzO5ufA2ElCEKgFUfg00/z/U=";
  };

  installPhase = ''
    mkdir -p $out/lib/firefox
    cp -r defaults/ legacy/ config.js legacy.manifest $out/lib/firefox
  '';

  meta = with lib; {
    description = "Monkeypatching Firefox Quantum to run VimFx";
    homepage = "https://git.gir.st/LegacyFox.git";
    license = licenses.mpl20;
  };
}
