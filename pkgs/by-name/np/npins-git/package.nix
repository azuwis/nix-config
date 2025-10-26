{
  npins,
  rustPlatform,
  nix-update-script,
}:

npins.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "0.3.1-unstable-2025-10-12";

    src = prevAttrs.src.override {
      rev = "f4e3698681704e74196fa0f905c7dfdd43cf5c86";
      tag = null;
      sha256 = "sha256-8lkiistkBemkRN4aTqGW3SvI1CqibOnvFvNJS9OOdnU=";
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
