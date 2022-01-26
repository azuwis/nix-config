{ lib, stdenvNoCC, fetchgit, font }:

stdenvNoCC.mkDerivation rec {
  pname = "nerdfonts";
  version = "2022-01-10";

  src = fetchgit {
    url = "https://github.com/ryanoasis/nerd-fonts.git";
    rev = "877887cac2d6ccc7354a8d95e8c39fff10bf120b";
    sparseCheckout = ''
      patched-fonts/${font}
    '';
    sha256 = "sha256-qBgyMc3CKIM98c61qMUitWudpkvyLq02LGFlavxmkn8=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp patched-fonts/${font}/*/complete/*Complete.ttf $out/share/fonts/truetype
  '';

  meta = with lib; {
    description = "Iconic font aggregator, collection, & patcher. 3,600+ icons, 50+ patched fonts";
    homepage = "https://nerdfonts.com/";
    license = licenses.mit;
  };
}
