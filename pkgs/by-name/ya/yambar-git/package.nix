{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2024-10-24";

  # yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  # tag: add '/N' formatter, https://codeberg.org/dnkl/yambar/pulls/403
  # Add niri-workspaces and niri-language modules https://codeberg.org/dnkl/yambar/pulls/405
  src = old.src.override {
    rev = "0a698558526d60997ae615b640826c003b5e95ce";
    hash = "sha256-IHJgblYwCfhqSzM9C/PalK4xNmV0usWgGaHGDIQUVAg=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=pull/405/head" ];
  };
})
