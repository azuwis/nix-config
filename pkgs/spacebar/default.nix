{ pkgs, lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "spacebar";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "cmacrae";
    repo = pname;
    rev = "v${version}";
    sha256 = "14rj56qhmdnllaqwv9iz56mf9qh3jcvk9110jk517c5bj91rxgbz";
  };

  buildInputs = with pkgs.darwin.apple_sdk.frameworks; [
    Carbon Cocoa ScriptingBridge SkyLight
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1/
    cp ./bin/spacebar $out/bin/spacebar
    cp ./doc/spacebar.1 $out/share/man/man1/spacebar.1
  '';

  meta = with lib; {
    description = "A minimal status bar for macOS";
    homepage = "https://github.com/cmacrae/spacebar";
    platforms = platforms.darwin;
    maintainers = [ maintainers.cmacrae ];
    license = licenses.mit;
  };
}
