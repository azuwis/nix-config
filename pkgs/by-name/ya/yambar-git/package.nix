{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2024-08-21";

  # yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  # tag: add 'b' formatter, https://codeberg.org/dnkl/yambar/issues/392
  src = old.src.override {
    rev = "8bd02d4a4f3f7bd1a271ac10757771969075912b";
    hash = "sha256-CTQkqvpjCxT6vUvkeP9eK79zepuKkzwu+7WhBiDWAl4=";
  };

  # https://codeberg.org/dnkl/yambar/pulls/401
  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=8bd02d4a4f3f7bd1a271ac10757771969075912b" ];
  };
})
