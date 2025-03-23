{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2025-03-20";

  # yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  # tag: add '/N' formatter, https://codeberg.org/dnkl/yambar/pulls/403
  # Add niri-workspaces and niri-language modules https://codeberg.org/dnkl/yambar/pulls/405
  src = old.src.override {
    rev = "43e19446071c49016d571bdb432e1a6e1e1e8778";
    hash = "sha256-erWbwhVj97JGdxwnPICmwAM2GeWyqUteI0VPhqzKWt4=";
  };

  passthru = (old.passthru or { }) // {
    updateScript = nix-update-script {
      extraArgs = [ "--version=branch" ];
    };
  };
})
