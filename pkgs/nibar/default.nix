{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  name = "nibar";
  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "nibar";
    rev = "c1ff38886e4c0bbcbd1490abb67b7d53a9ea58ba";
    sha256 = "1fcmkb42lhdya4xh8q29dp1nhn0fliaisl31m14sgiq0dva1cpac";
  };
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir $out/
    cp -r *.jsx config.json lib scripts $out/
  '';
}
