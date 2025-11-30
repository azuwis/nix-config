{
  npins,
  rustPlatform,
  nix-update-script,
}:

npins.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "0.3.1-unstable-2025-11-26";

    src = prevAttrs.src.override {
      rev = "84a362d77fb3c487ad759c80547facb028f4d96f";
      tag = null;
      sha256 = "sha256-EWA14ovB/5UFiK9fmEYtofIMbGnVeJ/4yK0aJEJXtsI=";
    };

    cargoHash = "sha256-YAIjrGQkmrurftV0fFP2s3BZSuNnpaFRGXZ89y+1tSc=";
    # rebuild cargoDeps by hand because `.overrideAttrs cargoHash`
    # does not reconstruct cargoDeps (a known limitation):
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) src;
      name = "${finalAttrs.pname}-${finalAttrs.version}";
      hash = finalAttrs.cargoHash;
    };

    passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  }
)
