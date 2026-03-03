{
  lib,
  stdenv,
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
  runtimeShell,
  coreutils,
  src,
  feeds,
  packages,
  downloadHash,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "openwrt-sdk";

  inherit src;

  download = stdenv.mkDerivation {
    name = "openwrt-sdk-download";

    inherit (finalAttrs) src;

    nativeBuildInputs = finalAttrs.nativeBuildInputs ++ [ cacert ];

    inherit (finalAttrs) postPatch configurePhase;

    dontBuild = true;

    installPhase = ''
      make ${lib.concatMapStringsSep " " (x: "package/${x}/download") packages} V=s
      cp -r dl $out
    '';

    outputHash = downloadHash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  nativeBuildInputs = [
    file
    git
    ncurses
    perl
    python3
    rsync
    unzip
    util-linux
    wget
    which
    zlib
    zstd
    # breakpointHook
  ];

  # Disable hardening to prevent Nix from interfering with the SDK toolchain
  hardeningDisable = [ "all" ];

  # Ref: https://github.com/astro/nix-openwrt-imagebuilder/blob/main/builder.nix
  postPatch = ''
    patchShebangs scripts staging_dir

    substituteInPlace rules.mk \
      --replace-quiet "/usr/bin/env bash" "${runtimeShell}" \
      --replace-quiet "/usr/bin/env true" "${coreutils}/bin/true" \
      --replace-quiet "/usr/bin/env false" "${coreutils}/bin/false"
  '';

  configurePhase = ''
    runHook preConfigure

    cat <<'EOF' >feeds.conf
    ${lib.concatMapAttrsStringSep "\n" (name: value: "src-link ${name} ${value}") feeds}
    EOF

    ./scripts/feeds update -a
    ./scripts/feeds install ${lib.concatStringsSep " " packages}

    make defconfig
    cat <<'EOF' >>.config
    ${lib.concatMapStringsSep "\n" (x: "CONFIG_PACKAGE_${x}=m") packages}
    EOF
    make defconfig

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    rmdir dl
    ln -s "$download" dl
    make ${lib.concatMapStringsSep " " (x: "package/${x}/compile") packages} V=s

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make package/index CONFIG_SIGNED_PACKAGES= V=s
    cp -r bin/packages/* $out

    runHook postInstall
  '';
})
