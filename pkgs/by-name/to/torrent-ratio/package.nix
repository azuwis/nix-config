{
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "torrent-ratio";
  version = "0.11";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "torrent-ratio";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-iJOOQNuWmD5++ZMmsK0Hq10QRufbBlOt5sXMmhp1jpQ=";
  };

  vendorHash = "sha256-+eqtiSDnAXlFqjOVunEDD862gf4k569/DLpmshQBJog=";

  passthru.updateScript = nix-update-script { };
})
