{
  lib,
  stdenv,
  fetchFromCodeberg,
  alsa-lib,
  bison,
  curl,
  fcft,
  flex,
  json_c,
  libmpdclient,
  libyaml,
  meson,
  ninja,
  pipewire,
  pixman,
  pkg-config,
  pulseaudio,
  scdoc,
  tllist,
  udev,
  wayland,
  wayland-protocols,
  wayland-scanner,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "maybar";
  version = "1.11.0-unstable-2026-05-27";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromCodeberg {
    owner = "mathstuf";
    repo = "maybar";
    rev = "793e6ee0cc329d53250ba054c82c74c3f4c239af";
    hash = "sha256-ZY1hI+9jmMr9UYs1z/BpTt8K01IxlF8BDQq5/T9otSU=";
  };

  outputs = [
    "out"
    "man"
    "dev"
  ];

  depsBuildBuild = [ pkg-config ];

  nativeBuildInputs = [
    bison
    flex
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs = [
    alsa-lib
    curl
    fcft
    json_c
    libmpdclient
    libyaml
    pipewire
    pixman
    pulseaudio
    tllist
    udev
    wayland
    wayland-protocols
  ];

  mesonBuildType = "release";

  mesonFlags = [
    (lib.mesonBool "werror" false)
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    homepage = "https://codeberg.org/mathstuf/maybar";
    description = "Modular status panel for Wayland";
    changelog = "https://codeberg.org/mathstuf/maybar/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "maybar";
  };
})
