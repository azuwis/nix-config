{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chnroutes2";
  version = "0-unstable-2025-09-13";

  src = fetchFromGitHub {
    owner = "misakaio";
    repo = "chnroutes2";
    rev = "d251eeab09a3c01ce4db53427f9b6b86bd3002a6";
    hash = "sha256-gfuCZa7ZQEai6/1WoIyE6QWtt08tKvVXNzHj7mLd590=";
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
