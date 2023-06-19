{ lib
, stdenv
, fetchFromGitHub
, cmake
, makeWrapper
, pkgconfig
, SDL2
, dbus
, libdecor
, libnotify
, dejavu_fonts
, gnome
}:

let
  inherit (gnome) zenity;
in

stdenv.mkDerivation rec {
  pname = "trigger-control";
  version = "unstable-2023-04-30";

  src = fetchFromGitHub {
    owner = "Etaash-mathamsetty";
    repo = "trigger-control";
    rev = "555acff24ffacd70685baf149924bc6a41b6c3bd";
    hash = "sha256-DVPE/3KYj2bkWPFLmR3+YpmLLCXQtiy6Bf928z2gA0o=";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkgconfig
  ];

  buildInputs = [
    SDL2
    dbus
    libnotify
  ] ++ lib.optionals stdenv.isLinux [
    libdecor
  ];

  postPatch = ''
    substituteInPlace trigger-control.cpp --replace "/usr/share/fonts/" "${dejavu_fonts}/share/fonts/"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp trigger-control $out/bin

    runHook postInstall
  '';

  postInstall = lib.optionalString stdenv.isLinux ''
    wrapProgram $out/bin/trigger-control \
      --prefix PATH : ${lib.makeBinPath [ zenity ]}
  '';

  meta = with lib; {
    description = "Control the dualsense's triggers on Linux (and Windows) with a gui and C++ api";
    homepage = "https://github.com/Etaash-mathamsetty/trigger-control";
    license = licenses.mit;
    maintainers = with maintainers; [ azuwis ];
  };
}
