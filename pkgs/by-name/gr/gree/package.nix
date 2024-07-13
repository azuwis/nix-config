{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
  nix-update-script,
}:

buildHomeAssistantComponent rec {
  owner = "RobHofmann";
  domain = "gree";
  version = "2.14.0";

  src = fetchFromGitHub {
    owner = "RobHofmann";
    repo = "HomeAssistant-GreeClimateComponent";
    rev = version;
    hash = "sha256-f4wKCZz3Aq5GWS5Yfs+kR3z1RNZtBkjz/0uxldoVwt4=";
  };

  propagatedBuildInputs = with home-assistant.python.pkgs; [ pycryptodome ];

  dontBuild = true;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Custom Gree climate component written in Python3 for Home Assistant. Controls AC's supporting the Gree protocol.";
    homepage = "https://github.com/RobHofmann/HomeAssistant-GreeClimateComponent";
    maintainers = with maintainers; [ azuwis ];
    license = licenses.gpl3;
  };
}
