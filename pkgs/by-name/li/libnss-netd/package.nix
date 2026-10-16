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
    rev = "9705484013d00e71aa1e47d6d779fb9da7ad2e10";
    hash = "sha256-foEne7I5/faC+F51/FfGXp+wfMH9X0QkitXfuCW08oQ=";
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
