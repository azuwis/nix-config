{
  lib,
  fetchFromGitHub,
  makeWrapper,
  stdenvNoCC,
  installShellFiles,
  shellcheck,
  nix,
  jq,
  man-db,
  coreutils,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  name = "nixos-option";

  src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "e558fe8ff4a392961d8400092ace653654f79e2a";
    hash = "sha256-dyFIQDdFRJBAsB5trbp+yuEa/HfKFj1JQH7ogZNZGq8=";
    sparseCheckout = [ "pkgs/tools/nix/nixos-option/" ];
    nonConeMode = true;
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    shellcheck
  ];

  env = {
    nixosOptionNix = "${finalAttrs.src}/pkgs/tools/nix/nixos-option/nixos-option.nix";
    nixosOptionManpage = "${placeholder "out"}/share/man";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontPatch = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm555 ${finalAttrs.src}/pkgs/tools/nix/nixos-option/nixos-option.sh $out/bin/nixos-option
    substituteAllInPlace $out/bin/nixos-option
    installManPage ${finalAttrs.src}/pkgs/tools/nix/nixos-option/nixos-option.8

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    shellcheck $out/bin/nixos-option
    runHook postInstallCheck
  '';

  postFixup = ''
    wrapProgram $out/bin/nixos-option \
      --prefix PATH : ${
        lib.makeBinPath [
          nix
          jq
          man-db
          coreutils
        ]
      }
  '';

  meta = {
    description = "Evaluate NixOS configuration and return the properties of given option";
    license = lib.licenses.mit;
    mainProgram = "nixos-option";
    maintainers = with lib.maintainers; [
      FireyFly
      azuwis
      aleksana
    ];
  };
})
