{
  lib,
  sunshine,
  boost186,
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
    version = "2024.1004.14216-unstable-2024-10-04";

    src = old.src.override {
      rev = "e90b71ce62b7744bb18ffc7823b1e895786ffb0a";
      hash = "sha256-D+HyoMjTpgWpoj1BRlfIVwRGMt10q6JIun/hhIt7L3E=";
    };

    patches = [ ];

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
