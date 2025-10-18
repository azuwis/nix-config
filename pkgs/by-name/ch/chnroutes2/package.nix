{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chnroutes2";
  version = "0-unstable-2025-10-18";

  src = fetchFromGitHub {
    owner = "misakaio";
    repo = "chnroutes2";
    rev = "b2ad5c9189381958f7c5561746cf2b0532774544";
    hash = "sha256-UrdXpFAN2it8nwcFjunI00u+sYOeFnNJp+oS8rpJFro=";
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
