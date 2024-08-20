{
  lib,
  stdenv,
  fetchzip,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vuetorrent";
  version = "2.12.0";

  src = fetchzip {
    url = "https://github.com/WDaan/VueTorrent/releases/download/v${finalAttrs.version}/vuetorrent.zip";
    sha256 = "sha256-JN9jbslu2B1h5WWtge2vR59ZGytRYuRP7njOBdu14Tk=";
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
