{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "simple-bar";
  version = "2021-08-12";
  src = fetchFromGitHub {
    owner = "Jean-Tinland";
    repo = "simple-bar";
    rev = "ede946b541f11c63d7aeb3719df18fba0f10d097";
    sha256 = "0l68c6qzm5r5zqm79v6zi49fm0ll16ass2l588xbd8krgajqcxs8";
  };
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir $out/
    cp -r *.jsx lib $out/
    substituteInPlace $out/lib/settings.js --replace /usr/local/bin/yabai /run/current-system/sw/bin/yabai
  '';
}
