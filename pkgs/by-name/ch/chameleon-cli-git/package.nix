{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  makeWrapper,
  openssl,
  python3,
  xz,
  nix-update-script,
}:

let
  # https://github.com/RfidResearchGroup/ChameleonUltra/blob/main/software/script/requirements.txt
  pythonPath =
    with python3.pkgs;
    makePythonPath [
      colorama
      prompt-toolkit
      pyserial
    ];
in

stdenv.mkDerivation (finalAttrs: {
  pname = "chameleon-cli";
  version = "2.2.0-unstable-2026-08-01";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "RfidResearchGroup";
    repo = "ChameleonUltra";
    rev = "9f90c3f8b95946816aa9cd6e141133a46affad2c";
    rootDir = "software";
    hash = "sha256-vbY1kU67fnVUlQYSx3oG/xKPKRWSUBVXfR9hk+MaoyA=";
  };

  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace-fail "liblzma" "lzma" \
      --replace-fail "FetchContent_MakeAvailable(xz)" ""
  '';

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    openssl
    xz
  ];

  cmakeFlags = [
    "-S"
    "../src"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec
    cp -r ../script/* $out/libexec
    rm -r $out/libexec/tests
    rm $out/libexec/requirements.txt
    makeWrapper ${lib.getExe python3} $out/bin/chameleon-cli \
      --add-flags "$out/libexec/chameleon_cli_main.py" \
      --prefix PYTHONPATH : ${pythonPath}

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--version-regex=v(.*)"
    ];
  };

  meta = {
    description = "Command line interface for Chameleon Ultra";
    homepage = "https://github.com/RfidResearchGroup/ChameleonUltra";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ azuwis ];
    mainProgram = "chameleon-cli";
  };
})
