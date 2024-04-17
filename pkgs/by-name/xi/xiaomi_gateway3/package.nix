{ lib
, buildHomeAssistantComponent
, fetchFromGitHub
, home-assistant
}:

buildHomeAssistantComponent rec {
  owner = "AlexxIT";
  domain = "xiaomi_gateway3";
  version = "3.3.4";

  src = fetchFromGitHub {
    owner = "AlexxIT";
    repo = "XiaomiGateway3";
    rev = "v${version}";
    hash = "sha256-nU28v9UuZiapNXkvU8uNze5gXxbnu+htn6vj6qFrPVs=";
  };

  propagatedBuildInputs = with home-assistant.python.pkgs; [
    zigpy
  ];

  dontBuild = true;

  meta = with lib; {
    description = "Control Zigbee, BLE and Mesh devices from Home Assistant with Xiaomi Gateway 3 on original firmware";
    homepage = "https://github.com/AlexxIT/XiaomiGateway3";
    maintainers = with maintainers; [ azuwis ];
    license = licenses.mit;
  };
}
