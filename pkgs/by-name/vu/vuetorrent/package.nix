{
  lib,
  stdenv,
  fetchzip,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vuetorrent";
  version = "2.11.1";

  src = fetchzip {
    url = "https://github.com/WDaan/VueTorrent/releases/download/v${finalAttrs.version}/vuetorrent.zip";
    sha256 = "sha256-VoG4voG+ptYSNfrQhg5zKDnfxS86/n1XfZJTYocs6NA=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/
    cp -r public/ $out/share/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The sleekest looking WEBUI for qBittorrent made with Vuejs";
    homepage = "https://github.com/VueTorrent/VueTorrent";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.all;
  };
})
