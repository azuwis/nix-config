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
    version = "2024.616.13035-unstable-2024-06-16";

    src = old.src.override {
      rev = "42aec263058f2ab59502ea4b55aae27e46c81de6";
      sha256 = "sha256-WN88q3p1K3YmMYJ0qMvKuDsTYvGxt3PlPTwX0jazktI=";
    };

    buildInputs = old.buildInputs ++ [ nodejs ];

    cmakeFlags = old.cmakeFlags ++ [ (lib.cmakeFeature "BOOST_USE_STATIC" "OFF") ];

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
        # "branch=42aec263058f2ab59502ea4b55aae27e46c81de6"
        # "branch=pull/2606/head"
      ];
    };
  })
