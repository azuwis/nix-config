{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chnroutes2";
  version = "0-unstable-2025-05-18";

  src = fetchFromGitHub {
    owner = "misakaio";
    repo = "chnroutes2";
    rev = "ddf37b83a0889dea45a7ab324b7e3885293978d5";
    hash = "sha256-uuvZMaiAIiXh3wex0QejRRaXs9qTZi0zAe6M4RUvjRw=";
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
