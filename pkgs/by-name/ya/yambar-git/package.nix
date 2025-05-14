{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2025-05-14";

  src = old.src.override {
    owner = "azuwis";
    rev = "123ec40cba2423ddc5a197626844d279182e89ee";
    hash = "sha256-FWCqhX2sqr7L6/LKNXYz8OlI0TjXfC3YGvoPsqu9G68=";
  };

  passthru = (old.passthru or { }) // {
    updateScript = nix-update-script {
      extraArgs = [ "--version=branch" ];
    };
  };
})
