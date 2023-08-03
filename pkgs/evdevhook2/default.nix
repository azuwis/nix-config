{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, vala
, glib
, libevdev
, libgee
, udev
}:

stdenv.mkDerivation {
  pname = "evdevhook2";
  version = "unstable-2023-08-03";

  src = fetchFromGitHub {
    owner = "v1993";
    repo = "evdevhook2";
    rev = "d9eb1440fd7b024c372858875f171548b3a4b753";
    hash = "sha256-PEHNfhMI/ERUQDHz+K6uPMM1QhL8XY6PZVKL2laoHtI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    glib
    libevdev
    libgee
    udev
  ];

  mesonBuildType = "release";

  meta = with lib; {
    description = "Cemuhook UDP server for devices with modern Linux drivers";
    homepage = "https://github.com/v1993/evdevhook2";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.linux;
  };
}
