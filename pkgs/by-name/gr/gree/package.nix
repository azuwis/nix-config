{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}:

buildHomeAssistantComponent rec {
  owner = "RobHofmann";
  domain = "gree";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "RobHofmann";
    repo = "HomeAssistant-GreeClimateComponent";
    rev = version;
    hash = "sha256-rrOUFSs4gHEXZcCB2aFkP2Vt1lyHvnmp2b60A6oJCvc=";
  };

  propagatedBuildInputs = with home-assistant.python.pkgs; [ pycryptodome ];

  dontBuild = true;

  meta = with lib; {
    description = "Custom Gree climate component written in Python3 for Home Assistant. Controls AC's supporting the Gree protocol.";
    homepage = "https://github.com/RobHofmann/HomeAssistant-GreeClimateComponent";
    maintainers = with maintainers; [ azuwis ];
    license = licenses.gpl3;
  };
}
