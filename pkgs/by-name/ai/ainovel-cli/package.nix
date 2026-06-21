{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "ainovel-cli";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "voocel";
    repo = "ainovel-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J+jvFEjCCZpK2Kzm4NCvTAoNpb2VMJ0Io+CwNOJWqDg=";
  };

  vendorHash = "sha256-zI8mDb8bECt5gfURxtm1kPfx4NDFaX5fj0ZLBvqeCKM=";

  subPackages = [ "cmd/ainovel-cli" ];

  ldflags = [
    "-X main.version=${finalAttrs.version}"
  ];

  meta = with lib; {
    description = "Automated AI novel creation CLI";
    homepage = "https://github.com/voocel/ainovel-cli";
    license = licenses.asl20;
    mainProgram = "ainovel-cli";
  };
})
