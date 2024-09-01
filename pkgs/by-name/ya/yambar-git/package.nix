{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2024-09-01";

  # yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  # tag: add 'b' formatter, https://codeberg.org/dnkl/yambar/issues/392
  src = old.src.override {
    rev = "642854047301351b032beca4deb8e7ed061cce1c";
    hash = "sha256-eWwYnYEulacFO1+sksManQc3gLfSThabIx84ziZ6yhg=";
  };

  # https://codeberg.org/dnkl/yambar/pulls/403
  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=642854047301351b032beca4deb8e7ed061cce1c" ];
  };
})
