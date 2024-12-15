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
    version = "2024.1214.152703-unstable-2024-12-14";

    src = old.src.override {
      rev = "e062484b469986193cc0c82887c8a748c439076a";
      hash = "sha256-d4XJ7khsqgRW8A1OkWtqvzdp8hFagwAKYcd7NkUqbXE=";
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
