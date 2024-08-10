{
  lib,
  sunshine,
  boost185,
  nodejs,
  cudaSupport ? false,
  nix-update-script,
}:

(sunshine.override {
  inherit cudaSupport;
  boost = boost185;
}).overrideAttrs
  (old: {
    pname = "sunshine-git";
    version = "2024.809.202917-unstable-2024-08-09";

    src = old.src.override {
      rev = "f9c885a414f92d8277337e2fd1283110a0e376bb";
      hash = "sha256-gsuhRk2gBLg+6VQzK3eW4xTroMSGR4MUgpyw4xFLb3g=";
    };

    patches = [ ];

    nativeBuildInputs = old.nativeBuildInputs ++ [ nodejs ];

    cmakeFlags = old.cmakeFlags ++ [
      (lib.cmakeFeature "BOOST_USE_STATIC" "OFF")
      (lib.cmakeFeature "BUILD_DOCS" "OFF")
    ];

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
        # "branch=42aec263058f2ab59502ea4b55aae27e46c81de6"
        # "branch=pull/2606/head"
      ];
    };

    # Workaround for nix-update 1.4.0, https://github.com/Mic92/nix-update/pull/247
    meta.homepage = old.meta.homepage;
  })
