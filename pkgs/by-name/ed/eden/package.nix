# https://gitlab.com/kira-bruneau/nur-packages/-/blob/main/pkgs/by-name/ed/eden/package.nix

{
  lib,
  stdenv,
  fetchFromGitea,
  cacert,
  cmake,
  glslang,
  pkg-config,
  python3,
  qt6Packages,
  vulkan-headers,
  boost,
  cpp-jwt,
  cubeb,
  enet,
  ffmpeg-headless,
  fmt,
  gamemode,
  httplib,
  libopus,
  libusb1,
  openssl,
  lz4,
  nlohmann_json,
  SDL2,
  simpleini,
  spirv-headers,
  vulkan-memory-allocator,
  vulkan-utility-libraries,
  zlib,
  zstd,
  vulkan-loader,
  pipewire,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eden";
  version = "0.2.0";

  src = fetchFromGitea {
    domain = "git.eden-emu.dev";
    owner = "eden-emu";
    repo = "eden";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q/tJP6AHAtW9AXn9G+8dF4oTlKDfNHN4cuTKXtYq0T8=";
  };

  deps = stdenv.mkDerivation {
    name = "eden-deps-${finalAttrs.version}.tar.gz";

    inherit (finalAttrs) src;

    nativeBuildInputs = finalAttrs.nativeBuildInputs ++ [ cacert ];

    inherit (finalAttrs) buildInputs __structuredAttrs cmakeFlags;

    dontBuild = true;

    installPhase = ''
      cd "$cmakeDir"
      # Build a reproducible tar, per instructions at https://reproducible-builds.org/docs/archives/
      tar --owner=0 --group=0 --numeric-owner --format=gnu \
        --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
        -czf $out .cache/cpm
    '';

    outputHash = "sha256-whgD7dfzXPf+RjbBUFO/Euweg77RZainXXoxDB/j2o0=";
    outputHashAlgo = "sha256";
  };

  nativeBuildInputs = [
    cmake
    glslang
    pkg-config
    python3
  ]
  ++ (with qt6Packages; [
    qttools
    wrapQtAppsHook
  ]);

  buildInputs = [
    # vulkan-headers must come first, so the older propagated versions
    # don't get picked up by accident
    vulkan-headers

    boost
    # intentionally omitted: catch2_3 - only used for tests
    cpp-jwt
    cubeb
    # intentionally omitted: discord-rpc - 0.1.0 need newer version
    # intentionally omitted: dynarmic - prefer vendored version for compatibility
    enet
    ffmpeg-headless
    fmt
    gamemode
    httplib
    libopus
    libusb1
    openssl
    # intentionally omitted: LLVM - heavy, only used for stack traces in the debugger
    lz4
    nlohmann_json
    # intentionally omitted: renderdoc - heavy, developer only
    SDL2
    # intentionally omitted: stb - header only libraries, vendor uses git snapshot
    simpleini
    spirv-headers
    # intentionally omitted: unordered_dense - cpm still download it even provided
    vulkan-memory-allocator
    vulkan-utility-libraries
    # intentionally omitted: xbyak - prefer vendored version for compatibility
    zlib
    zstd
  ]
  ++ (with qt6Packages; [
    qtbase
    qtcharts
    qtmultimedia
    qtwayland
    qtwebengine
    quazip
  ]);

  postUnpack = ''
    mkdir -p "$sourceRoot"
    tar -xf "$deps" -C "$sourceRoot"
  '';

  # Workaround for old vulkan-headers
  postPatch = ''
    substituteInPlace src/video_core/vulkan_common/vulkan_wrapper.cpp \
      --replace-fail 'case VK_DRIVER_ID_MESA_KOSMICKRISP:' "" \
      --replace-fail 'return "KosmicKrisp";' ""
  '';

  __structuredAttrs = true;
  cmakeFlags = [
    (lib.cmakeFeature "YUZU_BUILD_PRESET" "v3")

    # actually has a noticeable performance impact
    (lib.cmakeBool "ENABLE_LTO" true)
    (lib.cmakeBool "DYNARMIC_ENABLE_LTO" true)

    # enable some optional features
    (lib.cmakeBool "ENABLE_QT_TRANSLATION" true)
    (lib.cmakeBool "YUZU_USE_QT_MULTIMEDIA" true)
    (lib.cmakeBool "YUZU_USE_QT_WEB_ENGINE" true)

    (lib.cmakeFeature "TITLE_BAR_FORMAT_IDLE" "eden | ${finalAttrs.version} (nixpkgs) {}")
    (lib.cmakeFeature "TITLE_BAR_FORMAT_RUNNING" "eden | ${finalAttrs.version} (nixpkgs) | {}")
  ];

  postInstall = ''
    install -Dm444 "$src/dist/72-yuzu-input.rules" "$out/lib/udev/rules.d/72-yuzu-input.rules"
  '';

  preFixup = ''
    qtWrapperArgs+=(--prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        vulkan-loader
        pipewire
      ]
    })
  '';

  passthru = {
    # Hack to make `nix-update --subpackage depsUpdate` works
    depsUpdate = stdenv.mkDerivation {
      pname = "depsUpdate";
      version = "0";
      src = finalAttrs.deps;
    };
    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage=depsUpdate"
        "--version=unstable" # include `*-rc` version
        "--version-regex=^v([0-9.cr-]+)$" # but exclude `*test*`
      ];
    };
  };

  meta = {
    mainProgram = "eden";
    platforms = lib.platforms.linux;
    license = with lib.licenses; [
      gpl3Plus

      # Icons
      asl20
      mit
      cc0
    ];
  };
})
