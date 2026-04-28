{
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "torrent-ratio";
  version = "0.10";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "torrent-ratio";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-itIvizeedkN6VoTyHrraDV1yLC4v8dO8vzt5K0KRzq4=";
  };

  vendorHash = "sha256-+eqtiSDnAXlFqjOVunEDD862gf4k569/DLpmshQBJog=";

  passthru.updateScript = nix-update-script { };
})
