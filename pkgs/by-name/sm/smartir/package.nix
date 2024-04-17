{ lib
, buildHomeAssistantComponent
, fetchFromGitHub
, home-assistant
}:

buildHomeAssistantComponent rec {
  owner = "smartHomeHub";
  domain = "smartir";
  version = "1.17.8";

  src = fetchFromGitHub {
    owner = "smartHomeHub";
    repo = "SmartIR";
    rev = version;
    hash = "sha256-HlvWZ12aXZDa3tgaOgKnTcQCnr0l0Pc1GcxWj0oQYpQ=";
  };

  propagatedBuildInputs = with home-assistant.python.pkgs; [
    aiofiles
    broadlink
  ];

  dontBuild = true;

  postInstall = ''
    cp -r codes $out/custom_components/smartir/
  '';

  meta = with lib; {
    description = "Integration for Home Assistant to control climate, TV and fan devices via IR/RF controllers";
    homepage = "https://github.com/smartHomeHub/SmartIR";
    maintainers = with maintainers; [ azuwis ];
    license = licenses.mit;
  };
}
