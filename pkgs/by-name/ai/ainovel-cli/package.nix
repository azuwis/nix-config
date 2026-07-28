{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "ainovel-cli";
  version = "0.7.4";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "voocel";
    repo = "ainovel-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kCkB+BuCU7f422RyIUDYznTY8AWoyqVoR9SovQCnwNA=";
  };

  vendorHash = "sha256-h+q6SkvVoK8n+KdMDZkx5XEC7d9EVP17NwW7ngahsec=";

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
