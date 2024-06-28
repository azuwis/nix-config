{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  nix-update-script,
}:

buildHomeAssistantComponent {
  owner = "xcy1231";
  domain = "gree2";
  version = "0-unstable-2024-06-26";

  src = fetchFromGitHub {
    owner = "xcy1231";
    repo = "Ha-GreeCentralClimate";
    rev = "6c3f3e906f5832adaf8b41062717bd3085dd84f0";
    hash = "sha256-dbzevANt7ZvvICnmop97k+JLGynog94aIYIJTAGJm0w=";
  };

  dontBuild = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    homepage = "https://github.com/xcy1231/Ha-GreeCentralClimate";
    maintainers = with maintainers; [ azuwis ];
  };
}
