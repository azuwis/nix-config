{
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "torrent-ratio";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "torrent-ratio";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-UYlR4ArbY8oDq4dHUwGanLOmQS6QfMYwcBmlV6tzJ5s=";
  };

  vendorHash = "sha256-yDaALsAg+j9gQOTx4kdeCDE85talRsbbXzo/btdryYc=";

  passthru.updateScript = nix-update-script { };
})
