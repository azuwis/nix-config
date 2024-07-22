{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule {
  pname = "nix-search";
  version = "0.3.1-unstable-2024-07-15";

  src = fetchFromGitHub {
    owner = "diamondburned";
    repo = "nix-search";
    rev = "ab75c61cd01e3afe1f5dd4fc9e9e25f459aeb976";
    hash = "sha256-fsOEYRFeZjvLwedmUtkm9LbeTUox4cQc540oiikpJTc=";
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
