{
  lib,
  moonlight-qt,
  nix-update-script,
}:

moonlight-qt.overrideAttrs (old: {
  pname = "moonlight-git";
  version = "6.0.1-unstable-2024-07-25";

  src = old.src.override {
    rev = "da0244c5387cab3ccd682d8de24085720d6f6501";
    hash = "sha256-GKFRkG02EK6VVGHl4oFfiwlh5gpmi9BJjpOxS6O7ts8=";
  };

  patches = [ ];

  passthru.skipUpdate = true;
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
})
