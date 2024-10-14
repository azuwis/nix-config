{
  lib,
  stdenv,
  fetchzip,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vuetorrent";
  version = "2.14.1";

  src = fetchzip {
    url = "https://github.com/WDaan/VueTorrent/releases/download/v${finalAttrs.version}/vuetorrent.zip";
    sha256 = "sha256-pSXhRxhjB21Us/OgvbIXKhZtpXWZD+F1yb6/w/PQASs=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/
    cp -r public/ $out/share/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/VueTorrent/VueTorrent/releases/tag/v${finalAttrs.version}";
    description = "The sleekest looking WEBUI for qBittorrent made with Vuejs";
    homepage = "https://github.com/VueTorrent/VueTorrent";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.all;
  };
})
