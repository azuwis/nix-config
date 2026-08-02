{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "chnroutes2";
  version = "0-unstable-2026-08-02";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "misakaio";
    repo = "chnroutes2";
    rev = "d1d3df7ccdb7ce2b14777bc7df70fc0c5973d4cc";
    hash = "sha256-CKrURxFibx2XcV/0Y1vj2NuO9GO6+TncQj/xxPclV3Y=";
  };

  installPhase = ''
    runHook preInstall

    grep -v '^#' chnroutes.txt > "$out"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--version-regex=^(.*-0[1-7])$"
    ];
  };

  meta = {
    description = "Better aggregated chnroutes";
    homepage = "https://github.com/misakaio/chnroutes2";
    license = lib.licenses.cc-by-sa-40;
    maintainers = with lib.maintainers; [ azuwis ];
  };
})
