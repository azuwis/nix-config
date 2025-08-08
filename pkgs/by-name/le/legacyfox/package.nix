{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "legacyfox";
  version = "5.0";

  src = fetchFromGitHub {
    owner = "girst";
    repo = "LegacyFox-mirror-of-git.gir.st";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-lEwUSfZBZfqrwhwGRrZ6MbuF4aek3besrEsj6wITvGE=";
  };

  installPhase = ''
    mkdir -p $out/lib/firefox
    cp -r defaults/ legacy/ config.js legacy.manifest $out/lib/firefox
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Monkeypatching Firefox Quantum to run VimFx";
    homepage = "https://git.gir.st/LegacyFox.git";
    license = licenses.mpl20;
  };
})
