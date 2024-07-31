{
  lib,
  stdenvNoCC,
  fetchgit,
  nix-update-script,
  font ? "NerdFontsSymbolsOnly",
  hash ? "sha256-Sd6F2SJPTYvLhJelObLqbGbSMxbUZdVqvXSh4gogHjA=",
}:

stdenvNoCC.mkDerivation {
  pname = "nerdfonts-git";
  version = "3.2.1-unstable-2024-07-17";

  src = fetchgit {
    inherit hash;
    url = "https://github.com/ryanoasis/nerd-fonts.git";
    rev = "a2697b0fefe5e8d946c18a167a9496c6f224d7c9";
    sparseCheckout = [ "patched-fonts/${font}" ];
    nonConeMode = true;
  };

  installPhase = ''
    mkdir -p "$out/share/fonts/truetype/${font}"
    find "patched-fonts/${font}" -name \*.otf -or -name \*.ttf -exec mv {} "$out/share/fonts/truetype/${font}" \;
  '';

  # passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Iconic font aggregator, collection, & patcher. 3,600+ icons, 50+ patched fonts";
    homepage = "https://nerdfonts.com/";
    license = licenses.mit;
  };
}
