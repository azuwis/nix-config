{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  nix-update-script,
}:

buildHomeAssistantComponent {
  owner = "xcy1231";
  domain = "gree2";
  version = "0-unstable-2024-07-22";

  src = fetchFromGitHub {
    owner = "xcy1231";
    repo = "Ha-GreeCentralClimate";
    rev = "1fb3ec02fe8eb6c4081107892837fc242d638f22";
    hash = "sha256-YVzSBnhH51JxI4iCKzUG7GFTDwrHMkpIub+bdElbfc8=";
  };

  dontBuild = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    homepage = "https://github.com/xcy1231/Ha-GreeCentralClimate";
    maintainers = with maintainers; [ azuwis ];
  };
}
