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
    version = "2024.714.230159-unstable-2024-07-14";

    src = old.src.override {
      rev = "e34f44621031c3cc7c61fa75e0207d3028b6a611";
      sha256 = "sha256-1GvCiDcbGoswOZNiGlbJGIhfdlbJFa8AvNPYJzKFd0E=";
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
    meta.position = null;
  })
