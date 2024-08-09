{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  nix-update-script,
}:

buildHomeAssistantComponent {
  owner = "xcy1231";
  domain = "gree2";
  version = "0-unstable-2024-08-06";

  src = fetchFromGitHub {
    owner = "xcy1231";
    repo = "Ha-GreeCentralClimate";
    rev = "c657ec7e89a3bd5cc6333ee6789c1ec2e10efb7b";
    hash = "sha256-rsAe7tPevLMes+HKxuzQR6NtPXaKEeIklDi94sgVYrs=";
  };

  dontBuild = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    homepage = "https://github.com/xcy1231/Ha-GreeCentralClimate";
    maintainers = with maintainers; [ azuwis ];
  };
}
