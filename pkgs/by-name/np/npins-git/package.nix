{
  npins,
  rustPlatform,
  nix-update-script,
}:

npins.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "0.3.1-unstable-2025-09-21";

    src = prevAttrs.src.override {
      rev = "e49bcf58d66fa7f586aff687feae72c23e429672";
      tag = null;
      sha256 = "sha256-ZLrVWa7WU+IUXPAd6mR7B9c6FDZSiGgW8ClfW0SxbMs=";
    };

    cargoHash = "sha256-OrGkv0KXCrPleM+F7rwTIWVdFNhKdTniKCqWym4B9Ls=";
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
