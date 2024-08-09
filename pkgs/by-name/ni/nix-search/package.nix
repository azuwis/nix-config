{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule {
  pname = "nix-search";
  version = "0.3.1-unstable-2024-07-29";

  src = fetchFromGitHub {
    owner = "diamondburned";
    repo = "nix-search";
    rev = "607da43a32cfeb6a4e33ee76a0e166202fa85281";
    hash = "sha256-JQ+BMg2e7BLej+P2CDVSAX5AzADg+4LYFmd+r2Yae9E=";
  };

  vendorHash = "sha256-gdqTTc1YsO3feN+OBeBh6inrHfZvp/dio/TUC/Aaol0=";

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "A Nix-channel-compatible package search";
    homepage = "https://github.com/diamondburned/nix-search";
    license = licenses.gpl3Only;
    mainProgram = "nix-search";
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.all;
  };
}
