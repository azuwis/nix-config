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
    version = "2024.1222.851-unstable-2024-12-22";

    src = old.src.override {
      rev = "129abd8c26f3d42b6a742e78fa6f88895e81ea70";
      hash = "sha256-Mg/9MebCZA+XGfMdjNZkD92IMXh5kjECY1/xmONbQ2A=";
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
