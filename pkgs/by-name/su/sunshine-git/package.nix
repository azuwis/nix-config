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
    version = "2025.118.151840-unstable-2025-01-18";

    src = old.src.override {
      rev = "26566cc04db12c5bc7434e480cffa025ed838bce";
      hash = "sha256-sTZUHc1385qOmy2w3fjItIidCxnWeEjAaOFxfLBB65c=";
    };

    patches = [ ];

    buildInputs = old.buildInputs ++ [ nlohmann_json ];

    nativeBuildInputs = old.nativeBuildInputs ++ [ nodejs ];

    cmakeFlags = old.cmakeFlags ++ [
      (lib.cmakeFeature "BOOST_USE_STATIC" "OFF")
      (lib.cmakeFeature "BUILD_DOCS" "OFF")
      (lib.cmakeFeature "CUDA_FAIL_ON_MISSING" "OFF")
    ];

    passthru = (old.passthru or { }) // {
      updateScript = nix-update-script {
        extraArgs = [
          "--version"
          "branch"
          # "branch=42aec263058f2ab59502ea4b55aae27e46c81de6"
          # "branch=pull/2606/head"
        ];
      };
    };
  })
