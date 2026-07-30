{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
  nix-update-script,
}:

buildHomeAssistantComponent rec {
  owner = "syssi";
  domain = "xiaomi_miio_airconditioningcompanion";
  version = "2023.12.0.0";

  src = fetchFromGitHub {
    owner = "syssi";
    repo = "xiaomi_airconditioningcompanion";
    tag = version;
    hash = "sha256-wJYjeQjkUwhvGEZTcXUWKTu5DIIyGI4rP6RU7L4EcoM=";
  };

  propagatedBuildInputs = with home-assistant.python.pkgs; [ python-miio ];

  dontBuild = true;

  dontCheckManifest = true;

  passthru.enable = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Xiaomi Mi and Aqara Air Conditioning Companion integration for Home Assistant";
    homepage = "https://github.com/syssi/xiaomi_airconditioningcompanion";
    changelog = "https://github.com/syssi/xiaomi_airconditioningcompanion/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ azuwis ];
  };
}
