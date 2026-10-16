{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "ainovel-cli";
  version = "0.7.10";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "voocel";
    repo = "ainovel-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KewmhWZfhuQCSbihPscX0Ln0UE3FyOGpf+/P/lmv0Ik=";
  };

  vendorHash = "sha256-A1mr3jJ15kEGpco/jdAi45If5axjh3LOjtdg5zAKdiY=";

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
