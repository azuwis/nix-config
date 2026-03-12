{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6,
  ffmpeg-full,
  frei0r,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "amber-editor";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "baptisterajaut";
    repo = "amber";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-ZyrVGi6hWEOvhdXm8A52L+dE7FBf4q9y6MHuKMSd0ec=";
  };

  postPatch = ''
    substituteInPlace src/cmake/FindFFMPEG.cmake \
      --replace "NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH" ""
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.qttools.dev
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    ffmpeg-full
    frei0r
    qt6.qtbase
    qt6.qtmultimedia
  ];

  cmakeFlags = [
    "-S"
    "../src"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Amber Video Editor — free open-source non-linear video editor";
    homepage = "https://github.com/baptisterajaut/amber";
    license = lib.licenses.gpl3Plus;
    mainProgram = "amber-editor";
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.unix;
  };
})
