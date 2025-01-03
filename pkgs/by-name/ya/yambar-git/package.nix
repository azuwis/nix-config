{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2025-01-01";

  # yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  # tag: add '/N' formatter, https://codeberg.org/dnkl/yambar/pulls/403
  # Add niri-workspaces and niri-language modules https://codeberg.org/dnkl/yambar/pulls/405
  src = old.src.override {
    rev = "fc24ea225d0cb66c1e6949cecd584c21ad1af9d7";
    hash = "sha256-LfA5qWucGnldNqVRIJ8c3X6Odt4fD3e9JffmkPhF0Bw=";
  };

  passthru = (old.passthru or { }) // {
    updateScript = nix-update-script {
      extraArgs = [ "--version=branch" ];
    };
  };
})
