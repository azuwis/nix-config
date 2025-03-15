{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2025-03-05";

  # yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  # tag: add '/N' formatter, https://codeberg.org/dnkl/yambar/pulls/403
  # Add niri-workspaces and niri-language modules https://codeberg.org/dnkl/yambar/pulls/405
  src = old.src.override {
    rev = "e68ed8d8434e016041be944416def5c8d6e2d0ed";
    hash = "sha256-hIlZ1s5kvFZss4FG+UXg6qdth5hMfgAjQS3oTIILbJY=";
  };

  passthru = (old.passthru or { }) // {
    updateScript = nix-update-script {
      extraArgs = [ "--version=branch" ];
    };
  };
})
