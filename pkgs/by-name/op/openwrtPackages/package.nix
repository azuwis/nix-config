{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
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
  openwrtPackages,
  breakpointHook,
  src ? fetchurl {
    url = "https://downloads.openwrt.org/releases/24.10.5/targets/ramips/mt7621/openwrt-sdk-24.10.5-ramips-mt7621_gcc-13.3.0_musl.Linux-x86_64.tar.zst";
    hash = "sha256-8BqooKQ1VnpR74xhc/j+oh8DTWn8eZXKDQDlk+rK8nk=";
  },
  feeds ? {
    azuwis = fetchFromGitHub {
      owner = "azuwis";
      repo = "openwrt-azuwis";
      rev = "28bc9f81fc198d56eb987f28da3c4df43abd67e9";
      hash = "sha256-+a7ArFSGEI9R/7vabrvEwBZ5Atpdrydzky/Qj6swPF8=";
    };
    base = fetchFromGitHub {
      owner = "openwrt";
      repo = "openwrt";
      tag = "v24.10.5";
      hash = "sha256-gtrbBmR0dM6j+KKLd0Zv/x2cqeEs/jHtptlM1v4Kvaw=";
    };
    packages = fetchFromGitHub {
      owner = "openwrt";
      repo = "packages";
      rev = "953b6d47b4e9f0ad3c39547c6d3f9a828f10e206";
      hash = "sha256-tae7UKBydzLmszomkjRUqNKGDQbWJLcJPmDdc3z5fLg=";
    };
  },
  installs ? [ ],
  configText ? lib.concatMapStringsSep "\n" (x: "CONFIG_PACKAGE_${x}=m") installs,
  downloadHash ? "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=",
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
  name = "openwrt-packages";

  inherit src;

  download = stdenv.mkDerivation {
    name = "openwrt-packages-download";

    inherit (finalAttrs) src configurePhase;

    nativeBuildInputs = finalAttrs.nativeBuildInputs ++ [ cacert ];

    buildPhase = ''
      runHook preBuild
      ${lib.getExe fhs} <<'EOS'

      for package in package/feeds/*/*; do
        make "$package/download"
      done

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
    ./scripts/feeds install ${lib.concatStringsSep " " installs}

    cat <<'EOF' >.config
    CONFIG_ALL=n
    CONFIG_SIGNED_PACKAGES=n
    ${configText}
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

    make ${lib.concatMapStringsSep " " (x: "package/${x}/compile") installs}
    make package/index

    EOS
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r bin/packages/* $out

    runHook postInstall
  '';

  passthru = {
    feeds = builtins.attrNames feeds;
  }
  // (
    let
      packages = {
        shadowsocks-libev = {
          configText = ''
            CONFIG_PACKAGE_shadowsocks-libev-config=m
            CONFIG_PACKAGE_shadowsocks-libev-ss-local=m
            CONFIG_PACKAGE_shadowsocks-libev-ss-redir=m
            CONFIG_PACKAGE_shadowsocks-libev-ss-rules=m
            CONFIG_PACKAGE_shadowsocks-libev-ss-server=m
            CONFIG_PACKAGE_shadowsocks-libev-ss-tunnel=m
          '';
          downloadHash = "sha256-7g//IJVN1xigTi4PqTY9kXw8C5MoPDx/8o7UfBjlGiw=";
          installs = [ "shadowsocks-libev" ];
        };
        vlmcsd = {
          downloadHash = "sha256-1GdnxoH183ETtYLjrirrwbcUAKfptCQwv++I2Bly5ok=";
          installs = [ "vlmcsd" ];
        };
      };
      sdks = {
        ramips.mt7621 = {
          src = src;
        };
        ipq806x.generic = {
          src = fetchurl {
            url = "https://downloads.openwrt.org/releases/24.10.5/targets/ipq806x/generic/openwrt-sdk-24.10.5-ipq806x-generic_gcc-13.3.0_musl_eabi.Linux-x86_64.tar.zst";
            hash = "sha256-cD8CY5a0SbrrHSNMxJv7dQHOz99FQJ+huT1HcfpOkHQ=";
          };
        };
      };
    in
    builtins.mapAttrs (
      targetName: targetDef:
      builtins.mapAttrs (
        variantName: variantDef:
        builtins.mapAttrs (pkgName: pkgDef: openwrtPackages.override (variantDef // pkgDef)) packages
      ) targetDef
    ) sdks
  );
})
