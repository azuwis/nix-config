{ stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation {
  pname = "anime4k";
  version = "v4.0.0-RC";
  src = fetchzip {
    url = "https://github.com/bloc97/Anime4K/releases/download/v4.0.0-RC/Anime4K_v4.0.zip";
    stripRoot = false;
    sha256 = "0xfhmm45hbnab5kn763g3fxg8pc9kp45fg43nfgy10iplhva0lgv";
  };
  installPhase = ''
    mkdir $out
    cp *.glsl $out
  '';
}
