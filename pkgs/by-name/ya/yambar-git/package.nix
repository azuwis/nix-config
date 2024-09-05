{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2024-09-05";

  # yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  # tag: add '/N' formatter, https://codeberg.org/dnkl/yambar/pulls/403
  src = old.src.override {
    rev = "060586dbbeb9134ee0a8810d611fc08310da490a";
    hash = "sha256-ZRRxY6nPhZ/CD+oy2lNfxEHEWc8DGe3wmDosjILAt5Q=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
})
