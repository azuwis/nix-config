{
  lib,
  stdenv,
  requireFile,
  dpkg,
  makeWrapper,
  buildFHSEnv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "popo";
  version = "0";

  src = requireFile {
    hash = "sha256-Z1G7JJAJ2oZMnzXHqcq3pTBaYW65FHMthNb1kID77y0=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  fhsEnv = buildFHSEnv {
    name = "${finalAttrs.pname}-fhs-env";
    runScript = "";

    targetPkgs =
      pkgs: with pkgs; [
        xorg.libXrandr
        xdg-utils
        fontconfig
        freetype
        lsb-release
      ];

    multiPkgs =
      pkgs: with pkgs; [
        alsa-lib
        at-spi2-core
        cairo
        cups
        dbus
        expat
        glib
        krb5
        libdrm
        libglvnd
        libpulseaudio
        libxkbcommon
        mesa
        nspr
        nss
        pango
        udev
        wayland
        xorg.libX11
        xorg.libXScrnSaver
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrender
        xorg.libXtst
        xorg.libxcb
        xorg.libxshmfence
        zlib
      ];
  };

  unpackCmd = "dpkg -x $curSrc src";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/apps/popo
    mv opt/apps/popo/files $out/opt/apps/popo

    mkdir -p $out/share/applications/
    mv opt/apps/popo/entries/applications/popo.desktop $out/share/applications/popo.desktop

    makeWrapper ${finalAttrs.fhsEnv}/bin/${finalAttrs.pname}-fhs-env $out/bin/popo \
      --add-flags $out/opt/apps/popo/files/Elevator.sh \
      --argv0 popo

    # Replace absolute path in desktop file to correctly point to nix store
    substituteInPlace $out/share/applications/popo.desktop \
      --replace /opt/apps/popo/files/Elevator.sh $out/bin/popo

    patchelf --add-needed libudev.so.1 $out/opt/apps/popo/files/*/libcef.so

    runHook postInstall
  '';

  meta = with lib; {
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
})
