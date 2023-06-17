{ lib, stdenvNoCC, fetchgit, bash }:

stdenvNoCC.mkDerivation rec {
  pname = "steam-devices";
  version = "2023-05-09";

  src = fetchgit {
    url = "https://salsa.debian.org/games-team/steam-installer.git";
    rev = "99a8d1a5d69811d91631276d9ca20b4813a68b8d";
    sparseCheckout = [ "subprojects/steam-devices" ];
    hash = "sha256-R7DvCHNIWpbDvKZAdSHudUABXHZlIm9sfQiUgJrc7ZQ=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/udev/rules.d/
    cp subprojects/steam-devices/*.rules $out/lib/udev/rules.d/
    substituteInPlace $out/lib/udev/rules.d/*.rules --replace "/bin/sh" "${bash}/bin/sh"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Udev rules list for gaming devices";
    homepage = "https://salsa.debian.org/games-team/steam-installer/";
    license = licenses.mit;
  };
}
