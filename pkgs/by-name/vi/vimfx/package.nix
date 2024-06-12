{ buildFirefoxXpiAddon, nix-update-script }:

buildFirefoxXpiAddon rec {
  pname = "vimfx";
  version = "0.27.2";
  addonId = "VimFx-unlisted@akhodakivskiy.github.com";
  url = "https://github.com/akhodakivskiy/VimFx/releases/download/v${version}/VimFx.xpi";
  sha256 = "sha256-IiFnbp5nrfSgpyfnXt68F335cgpAvR8lXTsIos4D7Mk=";
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
