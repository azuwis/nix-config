{
  sunshine,
  nodejs,
  cudaSupport ? false,
  nix-update-script,
}:

(sunshine.override { inherit cudaSupport; }).overrideAttrs (old: {
  pname = "sunshine-git";
  version = "2024.615.30110-unstable-2024-06-14";

  src = old.src.override {
    rev = "a66dd260cc8caa1f81fd7365af44c235bb9dc77e";
    sha256 = "sha256-Rk4+lEHpHrP9aXmJ89RacWvrjGibjGbgrSrK4zoGC9Q=";
  };

  buildInputs = old.buildInputs ++ [ nodejs ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=a66dd260cc8caa1f81fd7365af44c235bb9dc77e"
      # "branch=pull/2606/head"
    ];
  };
})
