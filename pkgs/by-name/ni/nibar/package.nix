{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "nibar";
  version = "0-unstable-2021-08-20";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "nibar";
    rev = "ad68d5b8a934369748f356240d9ad2d3162e5ca6";
    sha256 = "1rs81rsbxckfhc75lzyyxf3xlqa2xdr0xbynp8pbcrlcsq1p2g4s";
  };

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    mkdir $out/
    cp -r *.jsx config.json lib scripts $out/
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Simple Übersicht status bar with yabai support";
    homepage = "https://github.com/azuwis/nibar";
    license = licenses.mit;
  };
}
