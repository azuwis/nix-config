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
    version = "2024.617.2357-unstable-2024-06-17";

    src = old.src.override {
      rev = "0c0b4c46107b0203d9412bfbca5e72dca6c0211e";
      sha256 = "sha256-GsZnW31MO5nXW9GBGLwS8gJFcUGojPV4iCM3GjM7GVE=";
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
