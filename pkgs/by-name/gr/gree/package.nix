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
  version = "2.14.2";

  src = fetchFromGitHub {
    owner = "RobHofmann";
    repo = "HomeAssistant-GreeClimateComponent";
    rev = version;
    hash = "sha256-nKegoYbbOHV2llMJhGVtHNqYKJO8rHREsP3CgRfponY=";
  };

  propagatedBuildInputs = with home-assistant.python.pkgs; [ pycryptodome ];

  dontBuild = true;

  # buildPythonPackage always set passthru.updateScript and can not be disabled,
  # override it with command `echo` to workaround
  passthru.updateScript = "echo";
  # passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Custom Gree climate component written in Python3 for Home Assistant. Controls AC's supporting the Gree protocol.";
    homepage = "https://github.com/RobHofmann/HomeAssistant-GreeClimateComponent";
    maintainers = with maintainers; [ azuwis ];
    license = licenses.gpl3;
  };
}
