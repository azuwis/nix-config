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
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "baptisterajaut";
    repo = "amber";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-IzMnyvNSFIjdKfoLQVKx7GGMN+RNVC9rNuBOhUMx4XM=";
  };

  # Fix `Could NOT find FFMPEG`
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

  # https://github.com/baptisterajaut/amber/blob/0.1.x/.github/workflows/build.yml
  # `Create .app bundle` step
  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall

    mkdir -p Amber.app/Contents/MacOS
    mkdir -p Amber.app/Contents/Resources
    cp Amber Amber.app/Contents/MacOS/Amber
    cp ../packaging/macos/olive.icns Amber.app/Contents/Resources/amber.icns
    cat > Amber.app/Contents/Info.plist <<PLIST
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleExecutable</key>
      <string>Amber</string>
      <key>CFBundleName</key>
      <string>Amber</string>
      <key>CFBundleIdentifier</key>
      <string>org.ambervideoeditor.Amber</string>
      <key>CFBundleVersion</key>
      <string>${finalAttrs.version}</string>
      <key>CFBundleShortVersionString</key>
      <string>${finalAttrs.version}</string>
      <key>CFBundleIconFile</key>
      <string>amber.icns</string>
      <key>CFBundlePackageType</key>
      <string>APPL</string>
    </dict>
    </plist>
    PLIST

    mkdir -p $out/Applications $out/bin
    mv Amber.app $out/Applications
    ln -s $out/Applications/Amber.app/Contents/MacOS/Amber $out/bin/${finalAttrs.meta.mainProgram}

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/baptisterajaut/amber/releases/tag/v${finalAttrs.version}";
    description = "Amber Video Editor — free open-source non-linear video editor";
    homepage = "https://github.com/baptisterajaut/amber";
    license = lib.licenses.gpl3Plus;
    mainProgram = "amber-editor";
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.unix;
  };
})
