{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  glibmm,
  libevdev,
  nlohmann_json,
  udev,
  zlib,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "evdevhook";
  version = "0-unstable-2023-08-03";

  src = fetchFromGitHub {
    owner = "v1993";
    repo = "evdevhook";
    rev = "55baeeaf12a1588c9941390b043908ff9fec0dc2";
    hash = "sha256-oRYR1pbYn+PdBDnkmorjQu+HOmyagYGctOHPOtd8gCI=";
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
    substituteInPlace src/main.cpp --replace-fail create_loopback create_any
  '';

  # passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Libevdev based DSU/cemuhook joystick server";
    homepage = "https://github.com/v1993/evdevhook";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.linux;
  };
}
