{
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  lib,
}:

stdenvNoCC.mkDerivation {
  pname = "fcitx5-fluent";
  version = "0.4.0-unstable-2024-07-15";

  src = fetchFromGitHub {
    owner = "Reverier-Xu";
    repo = "Fluent-fcitx5";
    rev = "b46d609b77f2e6ca01605d48fb452fa453a5e9ab";
    hash = "sha256-tVPp6kFgsWlSLcEUffOvXCWDEV0y7qcSqYKQkGO7lrM=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -pv $out/share/fcitx5/themes/
    cp -rv Fluent* $out/share/fcitx5/themes/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "A Fluent-Design theme with blur effect and shadow for fcitx5";
    homepage = "https://github.com/Reverier-Xu/Fluent-fcitx5";
    license = licenses.mpl20;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.all;
  };
}
