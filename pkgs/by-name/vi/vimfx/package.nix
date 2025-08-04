{ buildFirefoxXpiAddon, nix-update-script }:

buildFirefoxXpiAddon rec {
  pname = "vimfx";
  version = "0.27.4";
  addonId = "VimFx-unlisted@akhodakivskiy.github.com";
  url = "https://github.com/akhodakivskiy/VimFx/releases/download/v${version}/VimFx.xpi";
  sha256 = "sha256-X9Ax7H0UYk+WGz362dSHCrAXBDmC0/rWjqppHywj/zE=";
  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--override-filename"
      "pkgs/by-name/vi/vimfx/package.nix"
    ];
  };
  meta = {
    homepage = "https://github.com/akhodakivskiy/VimFx";
    description = "Vim keyboard shortcuts for Firefox";
  };
}
