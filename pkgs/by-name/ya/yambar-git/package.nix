{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2024-09-07";

  # yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  # tag: add '/N' formatter, https://codeberg.org/dnkl/yambar/pulls/403
  src = old.src.override {
    rev = "0f47cbb889716dcd0824b5501cab6f5f1cc85eac";
    hash = "sha256-ylHGM2Zk5sV7WieqtaRztSChif8WhMTjCUCzqQd2diQ=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
})
