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
    version = "2024.724.84421-unstable-2024-07-24";

    src = old.src.override {
      rev = "aa2cf8e5a9266d53b0e3ac2d7255b6854dfb574f";
      hash = "sha256-3x2b2WYFkrez6g0qGb+SJqCilcp2yTqu85wrtyJZtBI=";
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
