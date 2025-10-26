{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  makeWrapper,
  xz,
  python3,
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
  version = "2.1.0-unstable-2025-10-13";

  src = fetchFromGitHub {
    owner = "RfidResearchGroup";
    repo = "ChameleonUltra";
    rev = "97dfe5b9a41a6ea5535c6842afbe420098c4844b";
    sparseCheckout = [ "software" ];
    hash = "sha256-zFExh0vhzNcf02izgO4P4cWq3LoQpEHb4ZW7hsHZqNA=";
  };

  sourceRoot = "${finalAttrs.src.name}/software";

  patches = [
    # https://github.com/RfidResearchGroup/ChameleonUltra/pull/308
    (fetchpatch {
      url = "https://github.com/RfidResearchGroup/ChameleonUltra/commit/c14e6ccba22a5ce6fc93d2664fbfc5ccda8e1e6f.diff";
      relative = "software";
      hash = "sha256-GDgR6Pj4jT49sB7J5KyilbEFtbtmEsd3y1LKiYJRgdo=";
    })
    # https://github.com/RfidResearchGroup/ChameleonUltra/pull/307
    (fetchpatch {
      url = "https://github.com/RfidResearchGroup/ChameleonUltra/commit/dc212693a7d5b98d693d8dc630cf28c4959ef631.diff";
      relative = "software";
      hash = "sha256-YNZPLcSmfzq0xhpEmtl+hkPrnlxoF+ZdcH8BREsQT0A=";
    })
  ];

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

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Command line interface for Chameleon Ultra";
    homepage = "https://github.com/RfidResearchGroup/ChameleonUltra";
    license = lib.licenses.gpl3Only;
    mainProgram = "chameleon-cli";
    maintainers = with lib.maintainers; [ azuwis ];
  };
})
