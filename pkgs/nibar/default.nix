{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "nibar";
  version = "2021-04-09";
  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "nibar";
    rev = "ad68d5b8a934369748f356240d9ad2d3162e5ca6";
    sha256 = "1rs81rsbxckfhc75lzyyxf3xlqa2xdr0xbynp8pbcrlcsq1p2g4s";
  };
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir $out/
    cp -r *.jsx config.json lib scripts $out/
  '';
}
