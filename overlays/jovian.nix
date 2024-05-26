self: super: {
  # Steam (electron) have issues with variable noto cjk fonts
  # https://github.com/NixOS/nixpkgs/issues/178121
  # noto-fonts-cjk-sans = super.noto-fonts-cjk-sans.overrideAttrs (old: {
  #   src = old.src.override {
  #     sparseCheckout = [ "Sans/OTC" ];
  #     hash = "sha256-GXULnRPsIJRdiL3LdFtHbqTqSvegY2zodBxFm4P55to=";
  #   };
  #   installPhase = ''
  #     install -m444 -Dt $out/share/fonts/opentype/noto-cjk Sans/OTC/*.ttc
  #   '';
  # });
  # noto-fonts-cjk-serif = super.noto-fonts-cjk-serif.overrideAttrs (old: {
  #   src = old.src.override {
  #     sparseCheckout = [ "Serif/OTC" ];
  #     hash = "sha256-ihbhbv875XEHupFUzIdEweukqEmwQXCXCiTG7qisE64=";
  #   };
  #   installPhase = ''
  #     install -m444 -Dt $out/share/fonts/opentype/noto-cjk Serif/OTC/*.ttc
  #   '';
  # });
}
