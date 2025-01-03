{
  lib,
  sunshine,
  boost186,
  nlohmann_json,
  nodejs,
  cudaSupport ? false,
  nix-update-script,
}:

(sunshine.override {
  inherit cudaSupport;
  boost = boost186;
}).overrideAttrs
  (old: {
    pname = "sunshine-git";
    version = "2025.102.32311-unstable-2025-01-02";

    src = old.src.override {
      rev = "d50611c79bd8d49b88fa52456c1522b7845300f9";
      hash = "sha256-qApu0rQiDdSB7nGKFBc4s2iYVesEWJdlSYjiaVUzAnA=";
    };

    patches = [ ];

    buildInputs = old.buildInputs ++ [ nlohmann_json ];

    nativeBuildInputs = old.nativeBuildInputs ++ [ nodejs ];

    cmakeFlags = old.cmakeFlags ++ [
      (lib.cmakeFeature "BOOST_USE_STATIC" "OFF")
      (lib.cmakeFeature "BUILD_DOCS" "OFF")
      (lib.cmakeFeature "CUDA_FAIL_ON_MISSING" "OFF")
    ];

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
        # "branch=42aec263058f2ab59502ea4b55aae27e46c81de6"
        # "branch=pull/2606/head"
      ];
    };
  })
