{
  lib,
  stdenv,
  buildFHSEnv,
  bash,
  cacert,
  file,
  git,
  ncurses,
  perl,
  python3,
  rsync,
  unzip,
  util-linux,
  wget,
  which,
  zlib,
  zstd,
  breakpointHook,
  src,
  feeds,
  packages,
  downloadHash,
}:

let
  fhs = buildFHSEnv {
    name = "openwrt-sdk-fhs";
    targetPkgs = pkgs: [
      bash
      file
      git
      ncurses
      ncurses.dev
      perl
      python3
      rsync
      unzip
      util-linux
      wget
      which
      zlib
      zstd
    ];
    runScript = "bash -euo pipefail";
  };
in

stdenv.mkDerivation (finalAttrs: {
  name = "openwrt-sdk";

  inherit src;

  download = stdenv.mkDerivation {
    name = "openwrt-sdk-download";

    inherit (finalAttrs) src configurePhase;

    nativeBuildInputs = finalAttrs.nativeBuildInputs ++ [ cacert ];

    buildPhase = ''
      runHook preBuild
      ${lib.getExe fhs} <<'EOS'

      make ${lib.concatMapStringsSep " " (x: "package/${x}/download") packages} V=s

      EOS
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r dl $out

      runHook postInstall
    '';

    outputHash = downloadHash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  nativeBuildInputs = [
    fhs
    zstd
    # breakpointHook
  ];

  # Disable hardening to prevent Nix from interfering with the SDK toolchain
  hardeningDisable = [ "all" ];

  configurePhase = ''
    runHook preConfigure
    ${lib.getExe fhs} <<'EOS'

    cat <<'EOF' >feeds.conf
    ${lib.concatMapAttrsStringSep "\n" (name: value: "src-cpy ${name} ${value}") feeds}
    EOF

    ./scripts/feeds update -a
    chmod -R u+w feeds
    ./scripts/feeds install ${lib.concatStringsSep " " packages}

    make defconfig
    cat <<'EOF' >>.config
    ${lib.concatMapStringsSep "\n" (x: "CONFIG_PACKAGE_${x}=m") packages}
    EOF
    make defconfig

    EOS
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    ${lib.getExe fhs} <<'EOS'

    rmdir dl
    ln -s "${finalAttrs.download}" dl

    make ${lib.concatMapStringsSep " " (x: "package/${x}/compile") packages} V=s
    make package/index CONFIG_SIGNED_PACKAGES= V=s

    EOS
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r bin/packages/* $out

    runHook postInstall
  '';
})
