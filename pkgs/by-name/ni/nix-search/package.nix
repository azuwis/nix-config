{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule {
  pname = "nix-search";
  version = "0.4.0-unstable-2024-10-31";

  src = fetchFromGitHub {
    owner = "diamondburned";
    repo = "nix-search";
    rev = "868420cf077bc542f42db3e51b3bd87f3397d5d7";
    hash = "sha256-dOdcXKfSwi0THOjtgP3O/46SWoUY+T7LL9nGwOXXJfw=";
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
