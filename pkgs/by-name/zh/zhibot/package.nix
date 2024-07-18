{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
  nix-update-script,
}:

buildHomeAssistantComponent rec {
  owner = "Yonsm";
  domain = "zhibot";
  version = "0-unstable-2024-07-04";

  src = fetchFromGitHub {
    owner = "Yonsm";
    repo = "ZhiBot";
    rev = "0f180cac41da9c494f38bdfa1c9bd688568b59fb";
    hash = "sha256-FIEiQhpv9aDiut3MSZaqMv21QBhtOEIPx3p6GFGHUoc=";
  };

  dontBuild = true;

  # passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Uniform Bot Platform for HomeAssistant";
    homepage = "https://github.com/Yonsm/ZhiBot";
    maintainers = with lib.maintainers; [ azuwis ];
    license = lib.licenses.gpl3Only;
  };
}
