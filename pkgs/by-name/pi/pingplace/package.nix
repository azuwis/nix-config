{
  lib,
  fetchFromGitHub,
  darwin,
  swift,
  swiftPackages,
  nix-update-script,
}:

swiftPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "pingplace";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "NotWadeGrimridge";
    repo = "PingPlace";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yuifAi0Ce9/kwEAFpNL7G3exJ6qYW0gVqCbW32rvncs=";
  };

  nativeBuildInputs = [
    darwin.sigtool
    swift
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p PingPlace.app/Contents/MacOS
    mkdir -p PingPlace.app/Contents/Resources
    cp src/Info.plist PingPlace.app/Contents/
    cp src/assets/app-icon/icon.icns PingPlace.app/Contents/Resources/
    cp src/assets/menu-bar-icon/MenuBarIcon*.png PingPlace.app/Contents/Resources/
    swiftc src/PingPlace.swift -o PingPlace.app/Contents/MacOS/PingPlace

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r PingPlace.app $out/Applications

    runHook postInstall
  '';

  # Ad host signing does not work?
  # https://github.com/NotWadeGrimridge/PingPlace/blob/de66b4d881596d8e841831c698e4572ef38e34b2/Makefile#L13C2-L13C83
  # https://github.com/NotWadeGrimridge/PingPlace/commit/390c30b3f3c3b597d8ccb482d1d3a5ec978ccb57
  postFixup = ''
    codesign --entitlements src/PingPlace.entitlements -f -s - $out/Applications/PingPlace.app/Contents/MacOS/PingPlace
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Control notification position on macOS";
    homepage = "https://github.com/NotWadeGrimridge/PingPlace";
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.darwin;
  };
})
