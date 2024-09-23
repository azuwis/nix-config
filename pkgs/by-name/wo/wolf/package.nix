{
  lib,
  fetchFromGitHub,

  cacert,
  cargo,
  cmake,
  git,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook3,

  boost,
  curl,
  glib,
  gst_all_1,
  icu,
  libdrm,
  libevdev,
  libinput,
  libpulseaudio,
  libunwind,
  libxkbcommon,
  mesa,
  openssl,
  pciutils,
  pcre2,
  stdenv,
  udev,
  wayland,
}:

stdenv.mkDerivation {
  pname = "wolf";
  version = "unstable-2023-09-03";

  src = fetchFromGitHub {
    owner = "games-on-whales";
    repo = "wolf";
    rev = "f0d9f1ce8995d2f1e993529a0f82e70c2a6da71d";
    hash = "sha256-Toxy8chgJipRhYiT6NBjEc/0nPuK8lLOAGh1b8MKvyE=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "smithay-0.3.0" = "sha256-jrBY/r4IuVKiE7ykuxeZcJgikqJo6VoKQlBWrDbpy9Y=";
    };
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    cacert
    cargo
    cmake
    git
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook3
  ];

  buildInputs = [
    boost
    curl
    glib
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    icu
    libdrm
    libevdev
    libinput
    libpulseaudio
    libunwind
    libxkbcommon
    mesa
    openssl
    pciutils
    pcre2
    udev
    wayland
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
    "-DCMAKE_CXX_EXTENSIONS=OFF"
    "-DBUILD_SHARED_LIBS=OFF"
  ];

  installPhase = ''
    runHook preInstall

    install -D src/moonlight-server/wolf $out/bin/wolf

    runHook postInstall
  '';

  meta = with lib; {
    description = "Stream virtual desktops and games running in Docker";
    homepage = "https://github.com/games-on-whales/wolf";
    license = licenses.mit;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.linux;
  };
}
