{ lib, stdenvNoCC, fetchgit, font, sha256 }:

stdenvNoCC.mkDerivation rec {
  pname = "nerdfonts";
  version = "2022-02-24";

  src = fetchgit {
    inherit sha256;
    url = "https://github.com/ryanoasis/nerd-fonts.git";
    rev = "df6d602440f06695d3db372b45465632de264cc2";
    sparseCheckout = [ "patched-fonts/${font}" ];
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
