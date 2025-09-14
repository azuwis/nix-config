{
  npins,
  rustPlatform,
  nix-update-script,
}:

npins.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "0.3.1-unstable-2025-08-24";

    src = prevAttrs.src.override {
      rev = "e4683671e145c652c371b6b8ad9b0d757c88853c";
      tag = null;
      sha256 = "sha256-Nu86s1xok+1EFM0J9e55hrYPgfoutEZUDBpeXReCOaY=";
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
