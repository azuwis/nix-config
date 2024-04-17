{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, glibmm
, libevdev
, nlohmann_json
, udev
, zlib
}:

stdenv.mkDerivation {
  pname = "evdevhook";
  version = "unstable-2021-11-21";

  src = fetchFromGitHub {
    owner = "v1993";
    repo = "evdevhook";
    rev = "e82287051ceb78753193a0206c1fff048fe7987f";
    hash = "sha256-af9B04k8+7nO3rhsYx223N+fpcVjExi9KDXF+b719/8=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    glibmm
    libevdev
    nlohmann_json
    udev
    zlib
  ];

  postPatch = ''
    substituteInPlace src/main.cpp --replace create_loopback create_any
  '';

  meta = with lib; {
    description = "Libevdev based DSU/cemuhook joystick server";
    homepage = "https://github.com/v1993/evdevhook";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.linux;
  };
}
