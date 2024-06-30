{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "minimal-grub-theme";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "tomdewildt";
    repo = "minimal-grub-theme";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HQOP4g8oJXfo0HcTLzdHPDZakOokpy22+4v33PqH7To=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/

    cp -r minimal/theme.txt minimal/*.png $out/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Minimalistic GRUB theme insipired by primitivistical and vimix";
    homepage = "https://github.com/tomdewildt/minimal-grub-theme";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.linux;
  };
})
