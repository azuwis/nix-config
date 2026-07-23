{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "ainovel-cli";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "voocel";
    repo = "ainovel-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-brlkAnu+TigWfMSf0ax4wtk4aOGNQUzbR5lKEaVkJso=";
  };

  vendorHash = "sha256-SuTbdzSxaqGdF3d9PqhiLMIlDjs6T8EHrTbBmOA14bQ=";

  subPackages = [ "cmd/ainovel-cli" ];

  ldflags = [
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Automated AI novel creation CLI";
    homepage = "https://github.com/voocel/ainovel-cli";
    license = licenses.asl20;
    mainProgram = "ainovel-cli";
  };
})
