{ yambar, nix-update-script }:

yambar.overrideAttrs (old: {
  pname = "yambar-git";
  version = "1.11.0-unstable-2024-08-20";

  # yambar crash, https://codeberg.org/dnkl/yambar/issues/300
  # tag: add 'b' formatter, https://codeberg.org/dnkl/yambar/issues/392
  src = old.src.override {
    rev = "700bf5b28c3f060ed629ac9bf782e0ff2ec76636";
    hash = "sha256-9e5lYBtyObMfXFHr3iSELAk9Zm3EDDAJf6337N/C1o8=";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
})
