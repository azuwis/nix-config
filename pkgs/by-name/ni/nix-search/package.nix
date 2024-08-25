{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule {
  pname = "nix-search";
  version = "0.3.1-unstable-2024-08-24";

  src = fetchFromGitHub {
    owner = "diamondburned";
    repo = "nix-search";
    rev = "e616ac1c82a616fa6e6d8c94839c5052eb8c808d";
    hash = "sha256-h9yYOjL9i/m0r5NbqMcLMFNnwSKsIgfUr5qk+47pOtc=";
  };

  vendorHash = "sha256-bModWDH5Htl5rZthtk/UTw/PXT+LrgyBjsvE6hgIePY=";

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
