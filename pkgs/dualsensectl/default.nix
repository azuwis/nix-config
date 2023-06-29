{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, dbus
, hidapi
, udev
}:

stdenv.mkDerivation rec {
  pname = "dualsensectl";
  version = "unstable-2022-12-28";

  src = fetchFromGitHub {
    owner = "shadowwa";
    repo = "dualsensectl";
    rev = "5a18c27fb13355b4b36a0287baeb320f6db31c31";
    hash = "sha256-S791dNwM4HLE3ZLRTjXVgM/jywVshKWJk8b0MlCuyKY=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace "/usr/" "/"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    hidapi
    udev
  ];

  makeFlags = [
    "DESTDIR=$(out)"
  ];

  meta = with lib; {
    description = "Linux tool for controlling PS5 DualSense controller";
    homepage = "https://github.com/nowrep/dualsensectl";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.linux;
  };
}
