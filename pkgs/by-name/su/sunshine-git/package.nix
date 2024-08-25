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
    version = "2024.825.232033-unstable-2024-08-25";

    src = old.src.override {
      rev = "88ce5077b04e56a4b8717b67b685b1d47a0d0a00";
      hash = "sha256-xovyVAGPhSHMmHcz1ZMrZPE8S0lThc/zrOcSWXwi8A4=";
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
  })
