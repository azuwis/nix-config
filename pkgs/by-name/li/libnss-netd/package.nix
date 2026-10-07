{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnss-netd";
  version = "0-unstable-2026-10-07";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "libnss-netd";
    rev = "921ca20191c75ba602111d728c9237b71dfc3591";
    hash = "sha256-hKEQ4ybC+W3RAtgk0WSvgXARQ9caD0B6iNMp9jb3W2Q=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  nativeCheckInputs = [ python3 ];

  passthru = {
    # The timeout tests are slow, so run them through passthru.tests instead
    # of during the package build.
    tests.check = finalAttrs.finalPackage.overrideAttrs { doCheck = true; };
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "NSS module that resolves host names through Android's netd resolver";
    homepage = "https://github.com/azuwis/libnss-netd";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.linux;
  };
})
