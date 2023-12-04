{ lib
, buildHomeAssistantComponent
, fetchFromGitHub
, home-assistant
}:

buildHomeAssistantComponent rec {
  pname = "hass-xiaomi-miot";
  version = "0.7.13";

  src = fetchFromGitHub {
    owner = "al-one";
    repo = "hass-xiaomi-miot";
    rev = "v${version}";
    hash = "sha256-d49KRDwEjdrjIRizUjV1T8SXwK+YInQA6ALzLf7R5K8=";
  };

  propagatedBuildInputs = with home-assistant.python.pkgs; [
    hap-python
    micloud
    pyqrcode
    python-miio
  ];

  dontBuild = true;

  meta = with lib; {
    description = "Automatic integrate all Xiaomi devices to HomeAssistant via miot-spec, support Wi-Fi, BLE, ZigBee devices.";
    homepage = "https://github.com/al-one/hass-xiaomi-miot";
    maintainers = with maintainers; [ azuwis ];
    license = licenses.asl20;
  };
}
