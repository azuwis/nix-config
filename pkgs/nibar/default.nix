{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  name = "nibar";
  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "nibar";
    rev = "a1190d596041a6ba95b6b8c11c8d10aa269bb1a9";
    sha256 = "0pm1hq86pn30rkrz27xh9hi5fmm2swvv4fy9znwmskmc34h3dxpc";
  };
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir $out/
    cp -r *.jsx config.json lib scripts $out/
  '';
}
