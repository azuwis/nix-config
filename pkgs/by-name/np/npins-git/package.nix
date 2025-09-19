{
  npins,
  rustPlatform,
  nix-update-script,
}:

npins.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "0.3.1-unstable-2025-09-17";

    src = prevAttrs.src.override {
      rev = "208112c6c3b6c9ac38ffcde2bcfb6d8309e02cf5";
      tag = null;
      sha256 = "sha256-iHzirqpITtUAvJfLAmfL00Odr3R3tVj2J9l0lBQ3EaU=";
    };

    cargoHash = "sha256-dBMY5L9xzq3czs5fGHFXNqzQQvHO3+c6WRY8tVvIz20=";
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
