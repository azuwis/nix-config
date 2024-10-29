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
    version = "2024.1025.12635-unstable-2024-10-25";

    src = old.src.override {
      rev = "8810c5ccdd3327521eb41a1a17999d87095423b8";
      hash = "sha256-Ya41M7+AOLTESIB564V+MreynkCnA1nEzfWeWSHazJ4=";
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
