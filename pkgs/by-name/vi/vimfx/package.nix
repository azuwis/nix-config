{ buildFirefoxXpiAddon }:

buildFirefoxXpiAddon rec {
  pname = "vimfx";
  version = "0.26.4";
  addonId = "VimFx-unlisted@akhodakivskiy.github.com";
  url = "https://github.com/akhodakivskiy/VimFx/releases/download/v${version}/VimFx.xpi";
  sha256 = "sha256-8uVuk/oqOY6zE640GQ7nzBLGcxLvCHToqPLjuxdS428=";
  meta = {
    homepage = "https://github.com/akhodakivskiy/VimFx";
    description = "Vim keyboard shortcuts for Firefox";
  };
}
