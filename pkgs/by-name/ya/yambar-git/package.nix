{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2024-09-25";

  # yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  # tag: add '/N' formatter, https://codeberg.org/dnkl/yambar/pulls/403
  # Add niri-workspaces and niri-language modules https://codeberg.org/dnkl/yambar/pulls/405
  src = old.src.override {
    owner = "azuwis";
    rev = "992125aaf9a3db0a8c06dbebf52b3cda12b96aa5";
    hash = "sha256-tOjlRzQKg+rAso/COqiLTyLmLbhzffRBfSgJLLdW+gc=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=992125aaf9a3db0a8c06dbebf52b3cda12b96aa5" ];
  };
})
