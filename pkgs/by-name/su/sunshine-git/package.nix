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
    version = "2025.213.180858-unstable-2025-02-13";

    src = old.src.override {
      rev = "9aaa40c3ca69f514173922e63d4274cc613a506f";
      hash = "sha256-LdCb0nGlwATcUfaBZaoCOVH9OuC4EbLMoZIjwJbd87s=";
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
