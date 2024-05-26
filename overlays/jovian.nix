self: super: {
  # Workaround for vimPlugins.nvim-snippets not in jovia/nixpkgs yet.
  # Remove it when jovian upgrades next time.
  vimPlugins = super.vimPlugins // {
    nvim-snippets = self.vimUtils.buildVimPlugin {
      pname = "nvim-snippets";
      version = "2024-05-25";
      src = self.fetchFromGitHub {
        owner = "garymjr";
        repo = "nvim-snippets";
        rev = "343c687b463ff0c71febd4582076fa5b96214475";
        sha256 = "16r9vl52yf6r85x80jb53sx810vb7z08rxq2bq6qsjwh18ya8z0n";
      };
      meta.homepage = "https://github.com/garymjr/nvim-snippets/";
    };
  };

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
