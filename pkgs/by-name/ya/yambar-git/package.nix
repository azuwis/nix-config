{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2024-09-30";

  # yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  # tag: add '/N' formatter, https://codeberg.org/dnkl/yambar/pulls/403
  # Add niri-workspaces and niri-language modules https://codeberg.org/dnkl/yambar/pulls/405
  src = old.src.override {
    rev = "b9b82d3876ca9b740affe20191cd84801181e9c0";
    hash = "sha256-tOjlRzQKg+rAso/COqiLTyLmLbhzffRBfSgJLLdW+gc=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=b9b82d3876ca9b740affe20191cd84801181e9c0" ];
  };
})
