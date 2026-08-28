{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "ainovel-cli";
  version = "0.7.7";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "voocel";
    repo = "ainovel-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-S+ReIKmUjTcUQHrimYieKRWeGA4VOFnzwPjcTfcgWow=";
  };

  vendorHash = "sha256-onqNsFYFMlM0K+1Ml2OPg9khDAq4Z72d8ndmyqK27xo=";

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
