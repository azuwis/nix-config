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
    url = "https://downloads.openwrt.org/releases/25.12.0/targets/ramips/mt7621/openwrt-sdk-25.12.0-ramips-mt7621_gcc-14.3.0_musl.Linux-x86_64.tar.zst";
    hash = "sha256-NUna8RwYMkFEjpZfqihZ4m+6Gmdqdpv62ruiK2XJRpY=";
  },
  feeds ? {
    azuwis = fetchFromGitHub {
      owner = "azuwis";
      repo = "openwrt-azuwis";
      rev = "25701dc34df3d38c1a620a32866987c9cb354dbe";
      hash = "sha256-TYEEui5IeFYpbyoG16++0ImSBm0Pa7V8rTNM/Zee5xI=";
    };
    base = fetchFromGitHub {
      owner = "openwrt";
      repo = "openwrt";
      tag = "v25.12.0";
      hash = "sha256-v1Mw3DOnIYDQEbqwBryTzP4ZvBRPKPWmXl7URSxgdBE=";
    };
    packages = fetchFromGitHub {
      owner = "openwrt";
      repo = "packages";
      rev = "506c37591d7cd9b3cfd812e69e708349268f9865";
      hash = "sha256-HIuG+NLZeowphz438c5lXC3ZFuywnhnZ5G0ot4qv6Oc=";
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

  passthru =
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
          downloadHash = "sha256-8PK0wpa0i/eDgq5TvQUmC+8iHDmEeyIqacIjvvlUJdo=";
          installs = [ "shadowsocks-libev" ];
        };
        vlmcsd = {
          downloadHash = "sha256-3H7EPdauRNbzJYge8JXmjFKyhVSLK0k9yFCrQrEnBOg=";
          installs = [ "vlmcsd" ];
        };
      };
      sdks = {
        ramips.mt7621 = {
          src = src;
        };
        ipq806x.generic = {
          src = fetchurl {
            url = "https://downloads.openwrt.org/releases/25.12.0/targets/ipq806x/generic/openwrt-sdk-25.12.0-ipq806x-generic_gcc-14.3.0_musl_eabi.Linux-x86_64.tar.zst";
            hash = "sha256-gykaGjk0c+NNVubp/1HwtAxs9YorP5IrDyzweYeIK70=";
          };
        };
      };
    in
    {
      feeds = builtins.attrNames feeds;
    }
    # For `nix-update --version=skip openwrtPackages.<package>`
    // (builtins.mapAttrs (
      pkgName: pkgDef:
      stdenv.mkDerivation {
        pname = "download-update";
        version = "0";
        src = (openwrtPackages.override pkgDef).download;
      }
    ) packages)
    # For `nix-build -A openwrtPackages.<target>.<variant>.<package>`
    // (builtins.mapAttrs (
      targetName: targetDef:
      builtins.mapAttrs (
        variantName: variantDef:
        builtins.mapAttrs (pkgName: pkgDef: openwrtPackages.override (variantDef // pkgDef)) packages
      ) targetDef
    ) sdks);
})
