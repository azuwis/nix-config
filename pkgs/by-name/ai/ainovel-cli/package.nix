{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "ainovel-cli";
  version = "0.7.9";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "voocel";
    repo = "ainovel-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-To/Yn6fPNacpVfU7pYRLQ22dhYRNi5jLM++Bt2NieFY=";
  };

  vendorHash = "sha256-am7i0bcxS7bctxJ9r0Pb7HRfRPuZoxk5NhUvlyJ52t4=";

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
