{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chnroutes2";
  version = "0-unstable-2025-03-29";

  src = fetchFromGitHub {
    owner = "misakaio";
    repo = "chnroutes2";
    rev = "43a1ca43d55344bed103b888677aab64a5353baf";
    hash = "sha256-FMOuuvH61b7+pjCkfhdEuOdFMa7VlaR+jp2dPatb1ZY=";
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
