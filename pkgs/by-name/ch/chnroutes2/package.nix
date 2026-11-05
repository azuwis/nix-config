{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "chnroutes2";
  version = "0-unstable-2026-11-05";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "misakaio";
    repo = "chnroutes2";
    rev = "7ce59876cb45a8f99c0ad2b29c1e9f945b20b18c";
    hash = "sha256-MOcY/b2pHiGYvxce4Vfz2MXEdZGJELbsLro1HWma7e0=";
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
