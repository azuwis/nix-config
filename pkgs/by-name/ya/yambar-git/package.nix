{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2025-05-05";

  # yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  # tag: add '/N' formatter, https://codeberg.org/dnkl/yambar/pulls/403
  # Add niri-workspaces and niri-language modules https://codeberg.org/dnkl/yambar/pulls/405
  src = old.src.override {
    rev = "abeffbd9a9fd0b2133343e1149e65d4a795a43d0";
    hash = "sha256-6HHuZlvN+9bxBME0rT7I3yLzrcom+Z8M4Ctf14Iy8Ws=";
  };

  passthru = (old.passthru or { }) // {
    updateScript = nix-update-script {
      extraArgs = [ "--version=branch" ];
    };
  };
})
