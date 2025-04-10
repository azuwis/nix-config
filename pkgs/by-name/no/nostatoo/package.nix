{
  stdenv,
  ruby,
  fetchFromGitHub,
  writeScript,
  nix-update-script,
}:

let
  stub = writeScript "nostatoo" ''
    #!${ruby}/bin/ruby

    require_relative "../share/nostatoo/nostatoo"
  '';
in

# https://github.com/samueldr/nostatoo/blob/development/nostatoo.nix
stdenv.mkDerivation (finalAttrs: {
  pname = "nostatoo";
  version = "0-unstable-2024-10-17";

  src = fetchFromGitHub {
    owner = "samueldr";
    repo = "nostatoo";
    rev = "5b274cb03963b7fc7d295f6e53ae67d39531d016";
    hash = "sha256-UWVI3HofHRpy28hi8z/iFzPLgk0FeAH4K55RsfHL8Es=";
  };

  checkPhase = ''
    runHook preCheck

    ${ruby}/bin/ruby -c *.rb lib/*.rb

    runHook postCheck
  '';
  doCheck = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/nostatoo
    cp -r -t $out/share/nostatoo lib nostatoo.rb COPYING

    mkdir -p $out/bin
    cp ${stub} $out/bin/nostatoo

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
})
