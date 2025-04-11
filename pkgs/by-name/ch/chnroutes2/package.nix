{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chnroutes2";
  version = "0-unstable-2025-04-11";

  src = fetchFromGitHub {
    owner = "misakaio";
    repo = "chnroutes2";
    rev = "3557b39f001f9ec743943a7853e5369e83c52f86";
    hash = "sha256-PVxgZ5R4+BSx7wVoNZ2NhIPkr6t/XRBkwOCY/8vBTc4=";
  };

  installPhase = ''
    runHook preInstall

    grep -v '^#' chnroutes.txt > "$out"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Better aggregated chnroutes";
    homepage = "https://github.com/misakaio/chnroutes2";
    license = lib.licenses.cc-by-sa-40;
    maintainers = with lib.maintainers; [ azuwis ];
  };
})
