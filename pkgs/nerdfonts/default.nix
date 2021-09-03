{ pkgs, lib, stdenvNoCC, font }:

stdenvNoCC.mkDerivation rec {
  pname = "nerdfonts";
  version = "2021-04-26";

  src = pkgs.fetchgitSparse {
    url = "https://github.com/ryanoasis/nerd-fonts.git";
    rev = "bc4416e176d4ac2092345efd7bcb4abef9d6411e";
    sparseCheckout = ''
      patched-fonts/${font}
    '';
    sha256 = "04ag7p8jvs6628qfhkyh7w5584xc2d27iskwl7sq8anzjv5xmrlg";
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
