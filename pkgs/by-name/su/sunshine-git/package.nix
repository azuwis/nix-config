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
    version = "2024.819.132949-unstable-2024-08-19";

    src = old.src.override {
      rev = "17c4b26af0709b5414cc32546dd687beb0e1257c";
      hash = "sha256-rRxcbvs0mb/jQgfKxKFpxn26v/uMdSr2YFOmdDc9Ask=";
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
