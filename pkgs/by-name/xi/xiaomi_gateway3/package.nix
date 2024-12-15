{
  home-assistant-custom-components,
  nix-update-script,
}:

home-assistant-custom-components.xiaomi_gateway3.overridePythonAttrs (old: {
  version = "0-unstable-2024-11-29";

  src = old.src.override {
    owner = "CharmingCheung";
    rev = "6518451b57325cb8c757978934308c2624b4f26b";
    hash = "sha256-vPV298RqDehdAnTXreURzJB1N96NKKBaII0V1wxWc5c=";
  };

  passthru.isHomeAssistantComponent = true;
  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=linp.sensor_occupy.es2" ];
  };
})
