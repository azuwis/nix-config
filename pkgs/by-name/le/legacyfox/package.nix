{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "legacyfox";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "girst";
    repo = "LegacyFox-mirror-of-git.gir.st";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-zOc9eHw651yUdXviPOx9bplMKRelfkG7xRL+I4f6j+o=";
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
})
