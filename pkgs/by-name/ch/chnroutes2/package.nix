{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "chnroutes2";
  version = "0-unstable-2026-10-07";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "misakaio";
    repo = "chnroutes2";
    rev = "71dbc6e43b7817c495f95145718081e7d7bcac51";
    hash = "sha256-cn+bF8m/JNjRioJ9mYn0r6eOEl6JNbe27Qkrz7RY6ZI=";
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
