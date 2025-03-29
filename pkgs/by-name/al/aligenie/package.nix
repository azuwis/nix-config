{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  nix-update-script,
}:

buildHomeAssistantComponent {
  owner = "azuwis";
  domain = "aligenie";
  version = "0-unstable-2023-07-22";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "aligenie";
    rev = "626284b3a3e06d1f616e5d55f76ed58008c235c0";
    hash = "sha256-QxmiEP81HLDUX3vsO377+CfkxRki7yXrsbLXY/9AD80=";
  };

  dontBuild = true;

  passthru.enable = false;
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Home assistant custom component for tmall genie";
    homepage = "https://github.com/azuwis/aligenie";
    maintainers = with maintainers; [ azuwis ];
    license = licenses.mit;
  };
}
